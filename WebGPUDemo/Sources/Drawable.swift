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

public struct Drawable {
  let indexBuffer: GPUBuffer
  let vertexBuffer: GPUBuffer
  let uvBuffer: GPUBuffer
  let normalBuffer: GPUBuffer
  let matrixBuffer: GPUBuffer
  let viewProjectionMatrixBuffer: GPUBuffer
  let bindGroup: GPUBindGroup
  let indexCount: Int

  let albedoTexture: GPUTexture
  let normalTexture: GPUTexture
  let metalRoughnessTexture: GPUTexture

  var position: Vector4
  var scale: Vector4
  var rotation: Quaternion<Float>

  init(
    device: GPUDevice,
    bindGroupLayout: GPUBindGroupLayout,
    mesh: Mesh,
    position: Vector4,
    scale: Vector4,
    rotation: Quaternion<Float> = .identity,
    assets: Renderer.Assets,
  ) {
    func createTextureFromImage(_ image: ImageBitmap, label: String) -> GPUTexture {
      let texture = device.createTexture(
        descriptor: .init(
          label: label,
          size: .init([image.width, image.height]),
          format: .rgba8unorm,
          usage: (GPUTextureUsage.TEXTURE_BINDING | GPUTextureUsage.COPY_DST
            | GPUTextureUsage.RENDER_ATTACHMENT),
        )
      )

      device.queue.copyExternalImageToTexture(
        source: .init(source: .init(image), flipY: true),
        destination: .init(texture: texture),
        copySize: .init(.init(width: image.width, height: image.height)),
      )

      return texture
    }

    self.indexCount = mesh.indices.count
    self.scale = scale
    self.position = position
    self.rotation = rotation
    let vertices = Float32Array(length: mesh.vertices.count * 4)
    for (i, v) in mesh.vertices.enumerated() {
      let index = i * 4
      vertices[index] = v.x
      vertices[index + 1] = v.y
      vertices[index + 2] = v.z
      vertices[index + 3] = v.w
    }

    self.vertexBuffer = device.createBuffer(
      descriptor: .init(
        label: "Vertices",
        size: .init(vertices.lengthInBytes),
        usage: GPUBufferUsage.STORAGE | GPUBufferUsage.VERTEX | GPUBufferUsage.COPY_DST,
      )
    )
    device.queue.writeBuffer(
      buffer: vertexBuffer,
      bufferOffset: 0,
      data: .init(vertices.arrayBuffer),
      dataOffset: 0
    )

    let indices = Uint32Array(length: mesh.indices.count)
    for (i, v) in mesh.indices.enumerated() {
      indices[i] = v
    }

    indexBuffer = device.createBuffer(
      descriptor: .init(
        label: "Indices",
        size: .init(indices.lengthInBytes),
        usage:
          GPUBufferUsage.STORAGE | GPUBufferUsage.VERTEX | GPUBufferUsage.COPY_DST
      )
    )
    device.queue.writeBuffer(
      buffer: indexBuffer,
      bufferOffset: 0,
      data: .init(indices.arrayBuffer),
      dataOffset: 0
    )

    let uvs = Float32Array(length: mesh.uvs.count * 4)
    for (i, v) in mesh.uvs.enumerated() {
      let index = i * 2
      uvs[index] = v.x
      uvs[index + 1] = v.y
    }
    uvBuffer = device.createBuffer(
      descriptor: .init(
        label: "UVs",
        size: .init(uvs.lengthInBytes),
        usage:
          GPUBufferUsage.STORAGE | GPUBufferUsage.VERTEX | GPUBufferUsage.COPY_DST
      ),
    )
    device.queue.writeBuffer(
      buffer: uvBuffer,
      bufferOffset: 0,
      data: .init(uvs.arrayBuffer),
      dataOffset: 0
    )

    let normals = Float32Array(length: mesh.normals.count * 4)
    for (i, v) in mesh.normals.enumerated() {
      let index = i * 4
      normals[index] = v.x
      normals[index + 1] = v.y
      normals[index + 2] = v.z
      normals[index + 3] = v.w
    }
    normalBuffer = device.createBuffer(
      descriptor: .init(
        label: "Normals",
        size: .init(normals.lengthInBytes),
        usage: GPUBufferUsage.STORAGE | GPUBufferUsage.VERTEX | GPUBufferUsage.COPY_DST
      ),
    )
    device.queue.writeBuffer(
      buffer: normalBuffer,
      bufferOffset: 0,
      data: .init(normals.arrayBuffer),
      dataOffset: 0
    )

    matrixBuffer = device.createBuffer(
      descriptor: .init(
        label: "Model Matrix",
        size: .init(MemoryLayout<Float>.stride * 16),
        usage:
          GPUBufferUsage.STORAGE | GPUBufferUsage.VERTEX | GPUBufferUsage.COPY_DST
      )
    )

    viewProjectionMatrixBuffer = device.createBuffer(
      descriptor: .init(
        label: "View Projection Matrix",
        size: .init(MemoryLayout<Float>.stride * 16),
        usage: GPUBufferUsage.STORAGE | GPUBufferUsage.VERTEX | GPUBufferUsage.COPY_DST
      ),
    )
    albedoTexture = createTextureFromImage(assets.albedo, label: "Albedo")
    normalTexture = createTextureFromImage(assets.normal, label: "Normal")
    metalRoughnessTexture = createTextureFromImage(assets.metalRoughness, label: "MetalRoughness")

    let sampler = device.createSampler(
      descriptor: .init(
        addressModeU: .repeat,
        addressModeV: .repeat,
        magFilter: .linear,
      )
    )

    bindGroup = device.createBindGroup(
      descriptor: .init(
        label: "bind group",
        layout: bindGroupLayout,
        entries: [
          .init(binding: 0, resource: GPUBindingResource(.init(buffer: vertexBuffer))),
          .init(binding: 1, resource: GPUBindingResource(.init(buffer: indexBuffer))),
          .init(binding: 2, resource: GPUBindingResource(.init(buffer: uvBuffer))),
          .init(binding: 3, resource: GPUBindingResource(.init(buffer: normalBuffer))),
          .init(
            binding: 4,
            resource: GPUBindingResource.gpuTextureView(albedoTexture.createView())
          ),
          .init(binding: 5, resource: GPUBindingResource(normalTexture.createView())),
          .init(binding: 6, resource: GPUBindingResource(metalRoughnessTexture.createView())),
          .init(binding: 7, resource: GPUBindingResource(.init(buffer: matrixBuffer))),
          .init(binding: 8, resource: GPUBindingResource(sampler)),
          .init(
            binding: 9,
            resource: GPUBindingResource(.init(buffer: viewProjectionMatrixBuffer))
          ),
        ]
      )
    )
  }

  var matrix: Matrix4x4<Float> {
    let scaleM = Matrix4x4(
      axisX: scale.xVec,
      axisY: scale.yVec,
      axisZ: scale.zVec,
      translation: position
    )
    let transRotM = Matrix4x4(translation: position, rotation: rotation)

    return scaleM * transRotM
  }

  func updateMatrixBuffer(queue: GPUQueue, viewProjection: Matrix4x4<Float>) {
    func writeMatrix(_ m: Matrix4x4<Float>, buffer: GPUBuffer) {
      let matrixArray = Float32Array(length: 16)
      matrixArray[0] = m.axisX.x
      matrixArray[1] = m.axisX.y
      matrixArray[2] = m.axisX.z
      matrixArray[3] = m.axisX.w

      matrixArray[4] = m.axisY.x
      matrixArray[5] = m.axisY.y
      matrixArray[6] = m.axisY.z
      matrixArray[7] = m.axisY.w

      matrixArray[8] = m.axisZ.x
      matrixArray[9] = m.axisZ.y
      matrixArray[10] = m.axisZ.z
      matrixArray[11] = m.axisZ.w

      matrixArray[12] = m.translation.x
      matrixArray[13] = m.translation.y
      matrixArray[14] = m.translation.z
      matrixArray[15] = m.translation.w

      queue.writeBuffer(
        buffer: buffer,
        bufferOffset: 0,
        data: .init(matrixArray.arrayBuffer),
        dataOffset: 0
      )
    }

    writeMatrix(self.matrix, buffer: matrixBuffer)
    writeMatrix(viewProjection, buffer: viewProjectionMatrixBuffer)
  }

  public func draw(pass: GPURenderPassEncoder) {
    pass.setBindGroup(index: 0, bindGroup: bindGroup)
    pass.draw(vertexCount: .init(indexCount))
  }
}
