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

/// Stateful triangle-shaped waveform.
struct Triangle: Signal {
    /// The pitch parameter of the waveform that sets its tone.
    var pitch: Pitch

    /// The "volume" of the signal, i.e. the absolute boundary of the range in which this signal oscillates. Default
    /// amplitude of 1.0 means that samples returned from ``Triangle/next()`` will always stay in `-1.0...1.0` range.
    var amplitude: Float = 1.0

    /// The state managed by the underlying VultDSP implementation of the signal.
    var state = Triangle__ctx_type_0()

    mutating func next() -> Float {
        Triangle_process(&self.state, self.pitch.rawValue / 10.0, 0, 0) * self.amplitude
    }
}
