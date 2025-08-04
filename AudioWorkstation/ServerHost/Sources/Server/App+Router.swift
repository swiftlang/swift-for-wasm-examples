//===----------------------------------------------------------------------===//
//
// This source file is part of the Swift open source project
//
// Copyright (c) 2024 Apple Inc. and the Swift project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See http://swift.org/LICENSE.txt for license information
// See http://swift.org/CONTRIBUTORS.txt for the list of Swift project authors
//
//===----------------------------------------------------------------------===//

import Hummingbird
import NIOFileSystem
@preconcurrency import SystemPackage

let storagePath = FilePath(#filePath)
    .removingLastComponent()
    .removingLastComponent()
    .removingLastComponent()
    .appending("Public")

private let contentTypes = [
    "html": "text/html",
    "css": "text/css",
    "js": "text/javascript",
    "wasm": "application/wasm",
]

private func serveFile(path: FilePath) async throws -> Response {
    var headers = HTTPFields(dictionaryLiteral:
        (.contentType, contentTypes[path.extension ?? ""] ?? "application/octet-stream")
    )
    if let info = try await FileSystem.shared.info(forFileAt: path) {
        headers[.contentLength] = String(info.size)
    }

    return Response(
        status: .ok,
        headers: headers,
        body: ResponseBody { writer in
        try await FileSystem.shared.withFileHandle(forReadingAt: path) {
            for try await chunk in $0.readChunks() {
                try await writer.write(chunk)
            }
        }

        try await writer.finish(nil)
    })
}

enum UploadError: Error {
    case invalidFileName
}

func makeRouter() async throws -> Router<AppRequestContext> {
    Router(context: BasicRequestContext.self)
        .get("/") { _, _ in
            Response(
                status: .temporaryRedirect,
                headers: [.location: "/public/index.html"]
            )
        }

        .get("/public/index.html") { _, _ in
            let wasmModules = try await discoverModules(
                directory: storagePath,
                root: storagePath
            )

            return IndexPage(modules: wasmModules)
        }

        .post("/wasm-module/:name") { req, ctx in
            guard let fileName = ctx.parameters.get("name")
            else { throw UploadError.invalidFileName }

            try await FileSystem.shared.withFileHandle(
                forWritingAt: storagePath.appending(String(fileName)),
                options: .newFile(replaceExisting: true)
            ) {
                var offset: Int64 = 0
                for try await buffer in req.body {
                    let count = buffer.readableBytes
                    try await $0.write(contentsOf: buffer, toAbsoluteOffset: offset)
                    offset += Int64(count)
                }
            }

            return HTTPResponse.Status.ok
        }

        .get("/public/**") { req, ctx in
            let path = ctx.parameters.getCatchAll().joined(separator: "/")

            return try await serveFile(path: storagePath.appending(path))
        }

        .get("/mix") { _, _ in
            let wasmModules = try await discoverModules(
                directory: storagePath,
                root: storagePath
            )

            return try MixedOutput(modules: wasmModules)
        }
}
