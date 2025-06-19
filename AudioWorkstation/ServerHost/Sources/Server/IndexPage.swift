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

import Foundation
import Hummingbird
import _NIOFileSystem
@preconcurrency import SystemPackage

private func serveHTML(_ string: String) -> Response {
    .init(
        status: .ok,
        headers: .init(dictionaryLiteral: (.contentType, "text/html"), (.contentLength, "\(string.utf8.count)")),
        body: .init(byteBuffer: .init(string: string))
    )
}

struct IndexPage: ResponseGenerator, Sendable {
    struct Module: Sendable {
        let name: String
        let absolutePath: FilePath
        let relativePath: FilePath
    }

    var modules: [Module] = []

    var modulesList: String {
        if self.modules.isEmpty {
            """
            <h1 id="wasm-logger"><a href="/public/upload.html">Upload Wasm plugins</a> to get started</h1>
            """
        } else {
            """
            \(self.modules.sorted(using: KeyPathComparator(\.name, order: .forward)).map { module in
                """
                <h1 class="track-name">\(module.name)</h1>
                <div
                  class="plugin"
                  data-module-path="\(module.relativePath)"
                  style="display: flex; flex-direction: column; align-items: flex-start; gap: 1rem;"
                >
                  <canvas class="plotter" width="1000" height="210"></canvas>
                  <audio class="audio" type="audio.wav" controls></audio>
                </div>
                """
            }.joined(separator: "\n"))
            
            <h1 class="track-name">Mix</h1>
            <div
              id="tracks-mix"
              style="display: flex; flex-direction: column; align-items: flex-start; gap: 1rem;"
            >
              <canvas class="plotter" width="1000" height="210"></canvas>
              <audio class="audio" type="audio.wav" controls></audio>
            </div>
            """
        }
    }

    func response(from request: Request, context: some RequestContext) throws -> Response {
        serveHTML(
            """
            <html>
              <head>
                <meta charset="utf-8">
                <title>Swift Audio Workstation</title>
                <script type="module" src="/public/Sources/JavaScript/index.js">
                </script>
                <style>
                body {
                  background-color: black;
                  padding: 1rem;
                }
                #wasm-logger, .track-name {
                  font-family: sans-serif;
                  color: white;
                }
                #wasm-logger a, .track-name a {
                  color: #aabbcc;g
                }
                </style>
              </head>
              <body>
                \(self.modulesList)
              </body>
            </html>
            """
        )
    }
}

func discoverModules(directory: FilePath, root: FilePath) async throws -> [IndexPage.Module] {
    try await FileSystem.shared.withDirectoryHandle(atPath: directory) {
        var modules = [IndexPage.Module]()
        let dirContents = $0.listContents()

        for try await module in dirContents where module.type == .regular && module.path.isSynthModule {
            let absolutePath = module.path
            var relativePath = module.path
            _ = relativePath.removePrefix(root)
            modules.append(.init(
                name: module.path.lastComponent?.stem ?? "Module",
                absolutePath: absolutePath,
                relativePath: relativePath
            ))
        }

        return modules
    }
}

extension FilePath {
    var isSynthModule: Bool {
        self.extension == "wasm" && self.stem != "Plotter"
    }
}
