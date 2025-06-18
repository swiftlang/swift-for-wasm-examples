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

/// Abstract implementation of line drawing on a canvas. Platform-specific
/// implementation is required to provide these functions for drawing code in
/// this module to work.
protocol Canvas {
    static func beginPath(ctx: Int)
    static func stroke(ctx: Int)
    static func moveTo(ctx: Int, x: Int, y: Int)
    static func lineTo(ctx: Int, x: Int, y: Int)
}

struct HTMLCanvas: Canvas {
    @_extern(wasm, module: "canvas", name: "beginPath")
    @_extern(c)
    static func beginPath(ctx: Int)

    @_extern(wasm, module: "canvas", name: "stroke")
    @_extern(c)
    static func stroke(ctx: Int)

    @_extern(wasm, module: "canvas", name: "moveTo")
    @_extern(c)
    static func moveTo(ctx: Int, x: Int, y: Int)

    @_extern(wasm, module: "canvas", name: "lineTo")
    @_extern(c)
    static func lineTo(ctx: Int, x: Int, y: Int)
}
