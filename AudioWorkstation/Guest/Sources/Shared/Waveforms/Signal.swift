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

/// An abstract digital signal that produces an infinite amount of samples.
protocol Signal {
    /// Updates current state of the signal and produces the next sample.
    /// - Returns: The latest sample in this signal.
    mutating func next() -> Float
}
