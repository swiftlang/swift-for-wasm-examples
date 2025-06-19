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

import VultDSP

struct Noise: Signal {
    var state = Noise__ctx_type_1()
    var amplitude: Float = 1.0

    mutating func next() -> Float {
        Noise_process(&self.state, 1.0) * self.amplitude
    }
}

struct HiHat: SequencedInstrument {
    var currentStep: SequencerStep = .noteOff {
        didSet {
            switch self.currentStep {
            case .noteOff:
                self.core.modulation.isNoteOn = false
            case .noteOn:
                self.core.modulation.isNoteOn = true
            }
        }
    }

    var core = Modulator(
        source: Noise(),
        modulation: AttackHoldRelease(attack: 0.01, hold: 0.01, release: 0.2),
        sourceUpdate: { triangle, amplitude in
            triangle.amplitude = amplitude
        }
    )

    mutating func next() -> Float {
        self.core.next()
    }
}

struct Kick: SequencedInstrument {
    var state = Kick__ctx_type_1()

    var currentStep: SequencerStep = .noteOn(.e) {
        didSet {
            switch self.currentStep {
            case .noteOn(let pitch):
                Kick_controlChange(&state, 31, Int32(pitch.rawValue * 10), 0)
            case .noteOff:
                break
            }
        }
    }

    mutating func next() -> Float {
        switch self.currentStep {
        case .noteOff:
            Kick_process(&self.state, 0)
        case .noteOn:
            Kick_process(&self.state, 1)
        }
    }
}
