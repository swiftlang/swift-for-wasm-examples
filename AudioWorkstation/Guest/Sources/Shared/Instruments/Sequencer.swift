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

enum SequencerStep {
    case noteOff
    case noteOn(Pitch)
}

protocol SequencedInstrument: Signal {
    var currentStep: SequencerStep { get set }
}

struct Sequencer<Instrument: SequencedInstrument>: Signal {
    var instrument: Instrument

    let sequence: [SequencerStep]

    let stepLengthInSeconds: Float

    var currentSample = 0

    mutating func next() -> Float {
        let stepLengthInSamples = Int(stepLengthInSeconds * Float(sampleRate))
        var currentStepIndex = self.currentSample / stepLengthInSamples

        if currentStepIndex >= self.sequence.count {
            self.currentSample = self.currentSample % stepLengthInSamples
            currentStepIndex = 0
        }

        self.instrument.currentStep = self.sequence[currentStepIndex]
        self.currentSample += 1

        return self.instrument.next()
    }
}
