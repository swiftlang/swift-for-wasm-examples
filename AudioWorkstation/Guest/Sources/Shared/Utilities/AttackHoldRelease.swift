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

struct AttackHoldRelease: Signal {
    var state = Ahr__ctx_type_0()

    var attack: Float = 0.0
    var hold: Float = 0.5
    var release: Float = 0.5

    var isNoteOn = false

    mutating func next() -> Float {
        Ahr_do(&self.state, self.isNoteOn ? 1 : 0, self.attack, self.hold, self.release)
        return Ahr_do_ret_0(&self.state)
    }
}
