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

public func sin<T: BinaryFloatingPoint>(_ x: T) -> T {
  T(JSObject.global.Math.sin.function!(Float(x).jsValue).number!)
}

public func cos<T: BinaryFloatingPoint>(_ x: T) -> T {
  T(JSObject.global.Math.cos.function!(Float(x).jsValue).number!)
}

public func tan<T: BinaryFloatingPoint>(_ x: T) -> T {
  T(JSObject.global.Math.tan.function!(Float(x).jsValue).number!)
}

public func square(_ x: Float) -> Float {
  x * x
}

extension BinaryFloatingPoint {
  public func lerp(_ b: Self, _ s: Self) -> Self {
    self + (b - self) * s
  }
}

public typealias Vector2 = SIMD2<Float>
public typealias Vector4 = SIMD4<Float>

public extension SIMD4 where Scalar: BinaryFloatingPoint {
  var xVec: Self {
    .init(x: x, y: 0, z: 0, w: 0)
  }

  var yVec: Self {
    .init(x: 0, y: y, z: 0, w: 0)
  }

  var zVec: Self {
    .init(x: 0, y: 0, z: z, w: 0)
  }

  var wVec: Self {
    .init(x: 0, y: 0, z: 0, w: w)
  }

  static var oneX: Self {
    .init(x: 1, y: 0, z: 0, w: 0)
  }

  static var oneY: Self {
    .init(x: 0, y: 1, z: 0, w: 0)
  }

  static var oneZ: Self {
    .init(x: 0, y: 0, z: 1, w: 0)
  }

  static var oneW: Self {
    .init(x: 0, y: 0, z: 0, w: 1)
  }

  var length: Scalar {
    dot(self).squareRoot()
  }

  var normalized: Self {
    self / self.length
  }

  func dot(_ b: Self) -> Scalar {
    let xx = x * b.x
    let yy = y * b.y
    let zz = z * b.z
    let ww = w * b.w

    return xx + yy + zz + ww
  }
}

public struct Matrix4x4<Scalar: BinaryFloatingPoint & SIMDScalar> {
  public var axisX: SIMD4<Scalar>
  public var axisY: SIMD4<Scalar>
  public var axisZ: SIMD4<Scalar>
  public var translation: SIMD4<Scalar>

  init() {
    self.init(axisX: .zero, axisY: .zero, axisZ: .zero, translation: .zero)
  }

  init(axisX: SIMD4<Scalar>, axisY: SIMD4<Scalar>, axisZ: SIMD4<Scalar>, translation: SIMD4<Scalar>) {
    self.axisX = axisX
    self.axisY = axisY
    self.axisZ = axisZ
    self.translation = translation
  }

  init(rotation: Quaternion<Scalar>) {
    self.init(translation: .oneW, rotation: rotation)
  }

  init(translation: SIMD4<Scalar>, rotation: Quaternion<Scalar>) {
    let xq = rotation.a * rotation.components * 2
    let yq = rotation.b * rotation.components * 2
    let zq = rotation.c * rotation.components * 2

    self.axisX = .init(x: 1 - yq.y - zq.z, y: xq.y + zq.w, z: xq.z - yq.w, w: 0)
    self.axisY = .init(x: xq.y - zq.w, y: 1 - xq.x - zq.z, z: yq.z + xq.w, w: 0)
    self.axisZ = .init(x: xq.z + yq.w, y: yq.z - xq.w, z: 1 - xq.x - yq.y, w: 0)
    self.translation = translation
  }

  public static func * (a: Self, b: SIMD4<Scalar>) -> SIMD4<Scalar> {
    let x = a.axisX.x * b.x + a.axisY.x * b.y + a.axisZ.x * b.z + a.translation.x * b.w
    let y = a.axisX.y * b.x + a.axisY.y * b.y + a.axisZ.y * b.z + a.translation.y * b.w
    let z = a.axisX.z * b.x + a.axisY.z * b.y + a.axisZ.z * b.z + a.translation.z * b.w
    let w = a.axisX.w * b.x + a.axisY.w * b.y + a.axisZ.w * b.z + a.translation.w * b.w

    return .init(x: x, y: y, z: z, w: w)
  }

  public static func * (a: Self, b: Self) -> Self {
    let axisX = a * b.axisX
    let axisY = a * b.axisY
    let axisZ = a * b.axisZ
    let translation = a * b.translation

    return Matrix4x4(axisX: axisX, axisY: axisY, axisZ: axisZ, translation: translation)
  }

  public static func *= (a: inout Self, b: Self) {
    a = a * b
  }

  public var transposed: Self {
    return Matrix4x4(
      axisX: .init(x: axisX.x, y: axisY.x, z: axisZ.x, w: translation.x),
      axisY: .init(x: axisX.y, y: axisY.y, z: axisZ.y, w: translation.y),
      axisZ: .init(x: axisX.z, y: axisY.z, z: axisZ.z, w: translation.z),
      translation: .init(x: axisX.w, y: axisY.w, z: axisZ.w, w: translation.w)
    )
  }

  public static var identity: Self {
    .init(axisX: .oneX, axisY: .oneY, axisZ: .oneZ, translation: .oneW)
  }
}

public struct Quaternion<Scalar: BinaryFloatingPoint & SIMDScalar> {
  var components: SIMD4<Scalar>

  public init(components: SIMD4<Scalar>) {
    self.components = components
  }

  public init(a: Scalar, b: Scalar, c: Scalar, d: Scalar) {
    components = .init(x: a, y: b, z: c, w: d)
  }

  public init(axis: SIMD4<Scalar>, radians: Scalar) {
    let radHalf = radians * 0.5
    let sinR = sin(radHalf)
    let cosR = cos(radHalf)

    components = axis * sinR
    components.w = cosR

    components = components.normalized
  }

  public var a: Scalar {
    components.x
  }

  public var b: Scalar {
    components.y
  }

  public var c: Scalar {
    components.z
  }

  public var d: Scalar {
    components.w
  }

  public static func * (a: Self, b: Self) -> Self {
    let _a = a.a * b.d + a.b * b.c - a.c * b.b + a.d * b.a
    let _b = a.b * b.d - a.a * b.c + a.c * b.a + a.d * b.b
    let _c = a.c * b.d + a.a * b.b - a.b * b.a + a.d * b.c
    let _d = a.d * b.d - a.a * b.a - a.b * b.b - a.c * b.c
    return .init(a: _a, b: _b, c: _c, d: _d)
  }

  public static func * (a: Self, b: Scalar) -> Self {
    return .init(components: a.components * b)
  }

  public static func *= (a: inout Self, b: Self) {
    a = a * b
  }

  public func dot(_ b: Self) -> Scalar {
    return components.dot(b.components)
  }

  public static var identity: Self {
    .init(a: 0, b: 0, c: 0, d: 1)
  }
}
