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

// Equal temperament ratios: https://en.wikipedia.org/wiki/Equal_temperament#Comparison_with_just_intonation
struct Pitch {
    var rawValue: Float

    func octave(_ octaveShift: Int) -> Pitch {
        Pitch(rawValue: rawValue + Float(octaveShift))
    }

    static let c     = Pitch(rawValue: 0)
    static let dFlat = Pitch(rawValue: 0.059463)
    static let d     = Pitch(rawValue: 0.122462)
    static let eFlat = Pitch(rawValue: 0.189207)
    static let e     = Pitch(rawValue: 0.259921)
    static let f     = Pitch(rawValue: 0.33484)
    static let gFlat = Pitch(rawValue: 0.414214)
    static let g     = Pitch(rawValue: 0.498307)
    static let aFlat = Pitch(rawValue: 0.587401)
    static let a     = Pitch(rawValue: 0.681793)
    static let bFlat = Pitch(rawValue: 0.781797)
    static let b     = Pitch(rawValue: 0.887749)
}
