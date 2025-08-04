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

struct Modulator<Source: Signal, Modulation: Signal>: Signal {
    var source: Source
    var modulation: Modulation

    var sourceUpdate: (inout Source, Float) -> ()

    mutating func next() -> Float {
        self.sourceUpdate(&self.source, self.modulation.next())
        return self.source.next()
    }
}
