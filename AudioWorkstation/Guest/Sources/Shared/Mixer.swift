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

struct Mixer<Source1: Signal, Source2: Signal, Source3: Signal>: Signal {
    var source1: Source1
    var volume1: Float = 1.0

    var source2: Source2
    var volume2: Float = 1.0

    var source3: Source3
    var volume3: Float = 1.0

    mutating func next() -> Float {
        self.source1.next() * self.volume1 + self.source2.next() * self.volume2 + self.source3.next() * self.volume3
    }
}
