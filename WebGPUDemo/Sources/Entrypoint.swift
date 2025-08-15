//===----------------------------------------------------------------------===//
//
// This source file is part of the Swift.org open source project
//
// Copyright (c) 2025 Apple Inc. and the Swift project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
// See https://swift.org/CONTRIBUTORS.txt for the list of Swift project authors
//
//===----------------------------------------------------------------------===//

import _Concurrency
import DOM
import JavaScriptEventLoop
import JavaScriptKit
import WebAPIBase
import WebGPU

func fetchString(url: String) async throws(JSException) -> String {
  let result = try await Window.global.fetch(input: .init(url))
  return try await result.text()
}

func fetchImageBitmap(url: String) async throws(JSException) -> ImageBitmap {
  let blob = try await Window.global.fetch(input: .init(url)).blob()
  return try await Window.global.createImageBitmap(
    image: .blob(blob),
    options: .init(colorSpaceConversion: ColorSpaceConversion.none)
  )
}

typealias DefaultExecutorFactory = JavaScriptEventLoop

@main
struct Entrypoint {
  static func main() async {
    let gpu = Window.global.navigator.gpu

    do throws(JSException) {
      let adapterPromise: JSPromise = gpu.requestAdapter()
      let devicePromise = JSPromise(from: try await adapterPromise.value().requestDevice())!
      let device = try await GPUDevice(unsafelyWrapping: devicePromise.value().object!)

      let renderer = try await Renderer(
        device: device,
        gpu: gpu,
        assets: .init(
          shaders: fetchString(url: "Resources/shaders.wgsl"),
          model: fetchString(url: "Resources/SwiftLogo/Swift3DLogo.obj"),
          albedo: fetchImageBitmap(url: "Resources/SwiftLogo/T_M_swiftLogo_BaseColor.png"),
          normal: fetchImageBitmap(url: "Resources/SwiftLogo/T_M_swiftLogo_Normal.png"),
          metalRoughness: fetchImageBitmap(url: "Resources/SwiftLogo/T_M_swiftLogo_MetalRoughness.png"),
        ),
      )

      draw(renderer: renderer)
    } catch {
      console.error(data: error.thrownValue)
    }
  }
}
