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

/// Stateful square-shaped waveform. For values of ``Square/pulseWidth`` other than the default 0.5, strictly speaking
/// it produces a rectangular-shaped waveform.
struct Square: Signal {
    /// Frequency of oscillations in hertz.
    var frequency: Float {
        didSet {
            self.saw.frequency = self.frequency
        }
    }

    /// The "volume" of the signal, i.e. the absolute boundary of the range in which this signal oscillates. Default
    /// amplitude of 1.0 means that samples returned from ``Square/next()`` will always stay in `-1.0...1.0` range.
    var amplitude: Float

    /// The ratio of a width of a pulse in this waveform in the range of `0.0..<1.0`. The default value of 0.5 makes
    /// the pulse look like a square. Values smaller than 0.5 will make it more narrow, values larger than 0.5 make it
    /// wider.
    var pulseWidth: Float

    /// The underlying saw-shaped waveform used as a helper to compute samples.
    private var saw: Saw

    init(
        frequency: Float = 440.0,
        amplitude: Float = 1.0,
        pulseWidth: Float = 0.5
    ) {
        self.frequency = frequency
        self.amplitude = amplitude
        self.pulseWidth = pulseWidth
        self.saw = Saw(frequency: frequency, amplitude: amplitude)
    }

    mutating func next() -> Float {
        if abs(self.saw.next()) > pulseWidth {
            amplitude
        } else {
            -amplitude
        }
    }
}
