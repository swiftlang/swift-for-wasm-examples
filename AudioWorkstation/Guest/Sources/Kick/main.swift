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

@_expose(wasm, "main")
@_cdecl("main")
func main(contextIndex: Int) {
    var sequencedKick = Sequencer(
        instrument: Kick(),
        sequence: [.noteOff, .noteOn(.c.octave(1)), .noteOff, .noteOn(.c.octave(1))],
        stepLengthInSeconds: 0.25
    )

    let totalLengthInSeconds = 6

    let buffer = AudioBuffer(
        capacity: sampleRate * totalLengthInSeconds,
        source: &sequencedKick
    )

    Audio.encode(contextIndex: contextIndex, buffer)
}
