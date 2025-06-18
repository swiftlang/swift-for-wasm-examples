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

/// A non-copyable buffer of audio samples.
struct AudioBuffer: ~Copyable {
    let storage: UnsafeMutableBufferPointer<Float>

    /// Allocates an audio buffer and fills it with samples from a given signal.
    /// - Parameter capacity: the number of samples
    init(capacity: Int, source: inout some Signal) {
        self.storage = .allocate(capacity: capacity)

        for i in self.storage.indices {
            let sample = source.next()
            self.storage[i] = sample
        }
    }

    deinit {
        self.storage.deallocate()
    }
}
