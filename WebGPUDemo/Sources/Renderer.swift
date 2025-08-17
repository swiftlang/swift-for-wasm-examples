//===----------------------------------------------------------------------===//
//
// This source file is part of the Swift open source project
//
// Copyright (c) 2025 Apple Inc. and the Swift project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
// See https://swift.org/CONTRIBUTORS.txt for the list of Swift project authors
//
//===----------------------------------------------------------------------===//

import DOM
import WebGPU

func draw(renderer: Renderer) {
  _ = Window.global.requestAnimationFrame {
    renderer.render(timestamp: $0)
    draw(renderer: renderer)
  }
}

final class Renderer {
  struct Assets {
    let shaders: String
    let model: String
    let albedo: ImageBitmap
    let normal: ImageBitmap
    let metalRoughness: ImageBitmap
  }

  let device: GPUDevice
  let context: GPUCanvasContext
  let pipeline: GPURenderPipeline
  var lastTick: Double
  let rotation: Quaternion<Float>
  let passDescriptor: GPURenderPassDescriptor
  let depthTexture: GPUTexture
  let projectionMatrix: Matrix4x4<Float>
  var time: Double = 0.0
  var drawable: Drawable
  let multisampleTexture: GPUTexture

  init(device: GPUDevice, gpu: GPU, assets: Assets) {
    let window = Window.global
    let document = window.document

    let canvas = HTMLCanvasElement(unsafelyWrapping: document.createElement(localName: "canvas").jsObject)
    canvas.width = UInt32(window.innerWidth)
    canvas.height = UInt32(window.innerHeight)
    _ = document.body!.appendChild(node: canvas)

    context = canvas.getContext(GPUCanvasContext.self)!

    let format = gpu.getPreferredCanvasFormat()
    context.configure(
      configuration: .init(
        device: device,
        format: format,
      )
    )

    depthTexture =
      device.createTexture(
        descriptor: .init(
          size: .init([canvas.width, canvas.height]),
          sampleCount: 4,
          format: .depth24plus,
          usage: GPUTextureUsage.RENDER_ATTACHMENT,
        )
      )

    let canvasTexture = context.getCurrentTexture()
    multisampleTexture = device.createTexture(
      descriptor: .init(
        size: .init([canvasTexture.width, canvasTexture.height]),
        sampleCount: 4,
        format: canvasTexture.format,
        usage: GPUTextureUsage.RENDER_ATTACHMENT,
      )
    )

    passDescriptor = .init(
      label: "triangle render pass",
      colorAttachments: [
        .init(
          view: multisampleTexture.createView(),
          clearValue: .init([0.2, 0.2, 0.2, 1.0]),
          loadOp: .clear,
          storeOp: .store,
        )
      ],
      depthStencilAttachment:
        .init(
          view: depthTexture.createView(),
          depthClearValue: 1.0,
          depthLoadOp: .clear,
          depthStoreOp: .store,
        )
    )

    let module = device.createShaderModule(
      descriptor: .init(
        label: "shaders",
        code: assets.shaders,
      )
    )
    let bindGroupLayout = device.createBindGroupLayout(
      descriptor: .init(
        label: "bind group layout",
        entries: [
          .init(
            binding: 0,
            visibility: GPUShaderStage.VERTEX,
            buffer: .init(type: .readOnlyStorage)
          ),
          .init(
            binding: 1,
            visibility: GPUShaderStage.VERTEX,
            buffer: .init(type: .readOnlyStorage)
          ),
          .init(
            binding: 2,
            visibility: GPUShaderStage.VERTEX,
            buffer: .init(type: .readOnlyStorage)
          ),
          .init(
            binding: 3,
            visibility: GPUShaderStage.VERTEX,
            buffer: .init(type: .readOnlyStorage)
          ),
          .init(
            binding: 4,
            visibility: GPUShaderStage.FRAGMENT,
            texture: .init()
          ),
          .init(
            binding: 5,
            visibility: GPUShaderStage.FRAGMENT,
            texture: .init()
          ),
          .init(
            binding: 6,
            visibility: GPUShaderStage.FRAGMENT,
            texture: .init()
          ),
          .init(
            binding: 7,
            visibility: GPUShaderStage.VERTEX | GPUShaderStage.FRAGMENT,
            buffer: .init(type: .readOnlyStorage)
          ),
          .init(
            binding: 8,
            visibility: GPUShaderStage.FRAGMENT,
            sampler: .init()
          ),
          .init(
            binding: 9,
            visibility: GPUShaderStage.VERTEX | GPUShaderStage.FRAGMENT,
            buffer: .init(type: .readOnlyStorage)
          ),
        ]
      )
    )

    let pipelineLayout = device.createPipelineLayout(
      descriptor: .init(bindGroupLayouts: [
        bindGroupLayout  // @group(0)
      ])
    )

    pipeline = device.createRenderPipeline(
      descriptor: .init(
        // label: "pipeline",
        layout: .init(pipelineLayout),
        vertex: .init(
          module: module,
          entryPoint: "vs",
        ),
        primitive: .init(
          topology: .triangleList,
          frontFace: .ccw,
          cullMode: .back,
        ),
        depthStencil: .init(
          format: .depth24plus,
          depthWriteEnabled: true,
          depthCompare: .less,
        ),
        multisample: .init(count: 4),
        fragment: .init(
          module: module,
          entryPoint: "fs",
          targets: [.init(format: format)]
        ),
      )
    )
    self.device = device

    lastTick = Window.global.performance.timeOrigin
    rotation = Quaternion(axis: Vector4(x: 1.0, y: 1.0, z: 1.0, w: 0.0), radians: 3.14)

    let nearZ: Float = 0.001
    let farZ: Float = 1000.0
    let fov: Float = Float.pi / 3
    let aspect = Float(canvas.width) / Float(canvas.height)
    let va_tan = Float(1.0) / tan(fov * 0.5)
    let ys = va_tan
    let xs = ys / aspect
    let zs = -(farZ + nearZ) / (farZ - nearZ)
    let zss = -(2.0 * farZ * nearZ) / (farZ - nearZ)
    self.projectionMatrix = Matrix4x4(
      axisX: Vector4(x: xs, y: 0.0, z: 0.0, w: 0.0),
      axisY: Vector4(x: 0.0, y: ys, z: 0.0, w: 0.0),
      axisZ: Vector4(x: 0.0, y: 0.0, z: zs, w: -1.0),
      translation: Vector4(x: 0.0, y: 0.0, z: zss, w: 0.0)
    )

    let model = ObjParser().parse(text: assets.model)
    drawable = Drawable(
      device: device,
      bindGroupLayout: bindGroupLayout,
      mesh: model.meshes[0],
      position: Vector4(x: 0.0, y: 0.0, z: -1.5, w: 1.0),
      scale: Vector4(x: 0.1, y: 0.1, z: 0.1, w: 1.0),
      assets: assets,
    )
    let initialRad = 1.57079633 * (500 / 1000.0)
    let rotation = Quaternion(axis: .oneY, radians: Float(initialRad))
    drawable.rotation *= rotation
  }

  let pi: Double = 3.1415926

  func update(delta: Double) {
    let rad = 1.57079633 * (delta / 1000.0)
    let rotation = Quaternion(axis: .oneY, radians: Float(rad))
    drawable.rotation *= rotation
    drawable.updateMatrixBuffer(queue: device.queue, viewProjection: projectionMatrix)
  }

  func render(timestamp: Double) {
    let delta = max(0.0, timestamp - lastTick)
    lastTick = timestamp
    time += delta
    self.update(delta: delta)

    passDescriptor.colorAttachments[0]?.view = multisampleTexture.createView()
    passDescriptor.colorAttachments[0]?.resolveTarget = context.getCurrentTexture().createView()

    let encoder = device.createCommandEncoder(descriptor: .init(label: "command encoder"))

    let pass = encoder.beginRenderPass(descriptor: passDescriptor)
    pass.setPipeline(pipeline: pipeline)
    drawable.draw(pass: pass)
    pass.end()

    let commandBuffer = encoder.finish()
    device.queue.submit(commandBuffers: [commandBuffer])
  }
}
