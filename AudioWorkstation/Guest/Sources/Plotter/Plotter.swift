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

struct Plotter<CanvasType: Canvas> {
    let contextIndex: Int
    let height: Int
    let width: Int
    let centerY: Int
    let scaleFactor: Float

    init(contextIndex: Int, width: Int, height: Int, margin: Int) {
        self.contextIndex = contextIndex
        self.width = width
        self.height = height
        centerY = (height + margin) / 2
        scaleFactor = Float(height) / 4.0
    }

    func plot(_ audioBuffer: UnsafeBufferPointer<Float>) {
        let samplesPerPixel = audioBuffer.count / width

        var sampleCounter = 0
        var averageCounter = 0
        var average: Float = 0

        CanvasType.beginPath(ctx: contextIndex)
        CanvasType.moveTo(ctx: contextIndex, x: 0, y: centerY)
        for sample in audioBuffer {
            average += sample

            if sampleCounter < samplesPerPixel {
                sampleCounter += 1
                average += sample
            } else {
                CanvasType.lineTo(
                    ctx: contextIndex,
                    x: averageCounter,
                    y: centerY + Int(average * scaleFactor / Float(samplesPerPixel))
                )

                averageCounter += 1
                average = 0
                sampleCounter = 0
            }
        }

        if average != 0 {
            CanvasType.lineTo(
                ctx: contextIndex,
                x: averageCounter,
                y: centerY + Int(average * scaleFactor / Float(sampleCounter))
            )
        }

        CanvasType.stroke(ctx: contextIndex)
    }
}
