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

struct Bass: SequencedInstrument {
    var currentStep: SequencerStep = .noteOff {
        didSet {
            switch self.currentStep {
            case .noteOff:
                self.core.modulation.isNoteOn = false
            case .noteOn(let pitch):
                self.core.source.pitch = pitch
                self.core.modulation.isNoteOn = true
            }
        }
    }

    var core = Modulator(
        source: Triangle(pitch: .g),
        modulation: AttackHoldRelease(),
        sourceUpdate: { signal, amplitude in
            signal.amplitude = amplitude
        }
    )

    mutating func next() -> Float {
        self.core.next()
    }
}
