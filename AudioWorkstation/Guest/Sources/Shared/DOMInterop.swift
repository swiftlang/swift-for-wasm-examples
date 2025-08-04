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

@_extern(wasm, module: "console", name: "log")
@_extern(c)
private func consoleLog(ctx: Int, address: Int, byteCount: Int)

@_extern(wasm, module: "console", name: "logInt")
@_extern(c)
func consoleLogInt(_ int: Int)

@_extern(wasm, module: "console", name: "logFloat")
@_extern(c)
func consoleLogFloat(_ float: Float)

enum Console {
    static func log(contextIndex: Int, string: StaticString) {
        consoleLog(
            ctx: contextIndex,
            address: Int(bitPattern: string.utf8Start),
            byteCount: string.utf8CodeUnitCount
        )
    }
}
