// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

//===----------------------------------------------------------------------===//
//
// This source file is part of the Swift open source project
//
// Copyright (c) 2026 Apple Inc. and the Swift project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
// See https://swift.org/CONTRIBUTORS.txt for the list of Swift project authors
//
//===----------------------------------------------------------------------===//

import PackageDescription

let package = Package(
  name: "JSONBridge",
  dependencies: [
    .package(
      url: "https://github.com/swiftwasm/JavaScriptKit.git",
      from: "0.54.1"
    )
  ],
  targets: [
    .executableTarget(
      name: "JSONBridge",
      dependencies: [
        .product(name: "JavaScriptKit", package: "JavaScriptKit")
      ],
      swiftSettings: [
        .enableExperimentalFeature("Extern")
      ],
      plugins: [
        .plugin(name: "BridgeJS", package: "JavaScriptKit")
      ]
    )
  ]
)
