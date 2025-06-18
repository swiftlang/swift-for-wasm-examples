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

@_expose(wasm, "allocateAudioBuffer")
func allocateAudioBuffer(byteCount: Int) -> UnsafeRawPointer {
    let buffer = UnsafeMutableRawBufferPointer.allocate(
        byteCount: byteCount,
        alignment: MemoryLayout<Float>.alignment
    )

    return .init(buffer.baseAddress!)
}

@_expose(wasm, "free")
func free(pointer: UnsafeMutableRawPointer) {
    pointer.deallocate()
}

@_expose(wasm, "plot")
func plot(
    contextIndex: Int,
    width: Int,
    height: Int,
    margin: Int,
    start: UnsafeRawPointer,
    byteCount: Int
) {
    let plotter = Plotter<HTMLCanvas>(
        contextIndex: contextIndex,
        width: width,
        height: height,
        margin: margin
    )
    let samplesCount = byteCount / MemoryLayout<Float>.stride
    let buffer = UnsafeBufferPointer<Float>(
        start: start.assumingMemoryBound(to: Float.self),
        count: samplesCount
    )

    plotter.plot(buffer)
}
