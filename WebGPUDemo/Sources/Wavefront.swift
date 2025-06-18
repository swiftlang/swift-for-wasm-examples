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

import JavaScriptKit

extension UInt8 {
  static let newline = UInt8(ascii: "\n")
  static let space = UInt8(ascii: " ")
  static let forwardSlash = UInt8(ascii: "/")
}

public struct ObjParser {
  init() {}

  func parse(text: String) -> Model {
    var lines = text.utf8.lazy.split(separator: .newline).makeIterator()
    var meshes = [Mesh]()
    var builder = MeshBuilder()

    while let line = lines.next() {
      let parts = line.split(separator: .space)
      if parts.isEmpty {
        continue
      }

      switch parts[0] {
      case "o":
        if !builder.isEmpty {
          meshes.append(builder.mesh)
          builder = MeshBuilder()
        }

      case "v":
        if parts.count == 4 {
          builder.vertices.append(Vector4(x: Float(parts[1])!, y: Float(parts[2])!, z: Float(parts[3])!, w: 1.0))
        } else {
          builder.vertices.append(
            Vector4(x: Float(parts[1])!, y: Float(parts[2])!, z: Float(parts[3])!, w: Float(parts[4])!)
          )
        }

      case "vt":
        builder.uvs.append(Vector2(x: Float(parts[1])!, y: Float(parts[2])!))

      case "vn":
        builder.normals.append(Vector4(x: Float(parts[1])!, y: Float(parts[2])!, z: Float(parts[3])!, w: 1.0))

      case "f":
        guard parts.count == 4 else {
          fatalError("Can only support triangles")
        }
        func parseIndices(_ text: some Sequence<UInt8>) {
          let parts = text.split(separator: .forwardSlash, omittingEmptySubsequences: false)
          if parts.count >= 1 {
            builder.vertexIndices.append(UInt32(parts[0])! - 1)
          }
          if parts.count >= 2 && !parts[1].isEmpty {
            builder.uvIndices.append(UInt32(parts[1])! - 1)
          }
          if parts.count >= 3 {
            builder.normalIndices.append(UInt32(parts[2])! - 1)
          }
        }
        parseIndices(parts[1])
        parseIndices(parts[2])
        parseIndices(parts[3])

      default:
        continue
      }
    }

    if !builder.isEmpty {
      meshes.append(builder.mesh)
    }
    return Model(meshes: meshes)
  }
}

public struct Model {
  let meshes: [Mesh]
}

struct MeshBuilder {
  var vertices: [Vector4] = []
  var vertexIndices: [UInt32] = []
  var normals: [Vector4] = []
  var normalIndices: [UInt32] = []
  var uvs: [Vector2] = []
  var uvIndices: [UInt32] = []

  var isEmpty: Bool {
    vertices.isEmpty && vertexIndices.isEmpty && normals.isEmpty && normalIndices.isEmpty && uvs.isEmpty
      && uvIndices.isEmpty
  }

  var mesh: Mesh {
    var remappedVertices: [Vector4] = Array(repeating: .zero, count: vertexIndices.count)
    var remappedNormals: [Vector4] = Array(repeating: .zero, count: vertexIndices.count)
    var remappedUVs: [Vector2] = Array(repeating: .zero, count: vertexIndices.count)
    for (n, index) in normalIndices.enumerated() {
      remappedNormals[n] = normals[Int(index)]
    }

    for (n, index) in uvIndices.enumerated() {
      remappedUVs[n] = uvs[Int(index)]
    }

    for (n, index) in vertexIndices.enumerated() {
      remappedVertices[n] = vertices[Int(index)]
    }

    return Mesh(
      vertices: remappedVertices,
      indices: vertexIndices,
      normals: remappedNormals,
      uvs: remappedUVs
    )
  }
}

public struct Mesh {
  public let vertices: [Vector4]
  public let indices: [UInt32]
  public let normals: [Vector4]
  public let uvs: [Vector2]
}

extension Float {
  init?(_ text: some Collection<UInt8>) {
    let text = String(decoding: text, as: UTF8.self)
    guard let parsed = JSObject.global.parseFloat!(text).number else {
      return nil
    }
    self.init(parsed)
  }
}

extension UInt32 {
  init?(_ text: some Collection<UInt8>) {
    let text = String(decoding: text, as: UTF8.self)
    self.init(text)
  }
}

extension String {
  static func ~= (lhs: Self, rhs: some Collection<UInt8>) -> Bool {
    let lhs = lhs.utf8
    guard lhs.count == rhs.count else { return false }
    var lhsIndex = lhs.startIndex
    var rhsIndex = rhs.startIndex
    while lhsIndex < lhs.endIndex {
      guard lhs[lhsIndex] == rhs[rhsIndex] else { return false }
      lhs.formIndex(after: &lhsIndex)
      rhs.formIndex(after: &rhsIndex)
    }
    return true
  }
}
