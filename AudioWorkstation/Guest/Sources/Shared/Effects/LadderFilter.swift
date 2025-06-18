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

struct LadderFilter<Source: Signal>: Signal {
    var source: Source

    var cutoff: Float = 0
    var resonance: Float = 0.0

    var state = Ladder__ctx_type_4()

    mutating func next() -> Float {
        Ladder_heun(&self.state, self.source.next(), self.cutoff, self.resonance)
    }
}
