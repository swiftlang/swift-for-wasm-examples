//===----------------------------------------------------------------------===//
//
// This source file is part of the Swift open source project
//
// Copyright (c) 2024 Apple Inc. and the Swift project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
// See https://swift.org/CONTRIBUTORS.txt for the list of Swift project authors
//
//===----------------------------------------------------------------------===//

@_extern(wasm, module: "audio", name: "encode")
@_extern(c)
private func encodeAudio(ctx: Int, address: Int, byteCount: Int)

enum Audio {
    static func encode(contextIndex: Int, _ buffer: borrowing AudioBuffer) {
        buffer.storage.withContiguousStorageIfAvailable {
            encodeAudio(
                ctx: contextIndex,
                address: Int(bitPattern: $0.baseAddress!),
                byteCount: MemoryLayout<Float>.stride * $0.count
            )
        }
    }
}
