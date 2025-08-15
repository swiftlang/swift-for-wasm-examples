// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

//===----------------------------------------------------------------------===//
//
// This source file is part of the Swift open source project
//
// Copyright (c) 2024 Apple Inc. and the Swift project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See http://swift.org/LICENSE.txt for license information
// See http://swift.org/CONTRIBUTORS.txt for the list of Swift project authors
//
//===----------------------------------------------------------------------===//

import PackageDescription

let linkerSettings: [LinkerSetting] = [
  .unsafeFlags([
    "-Xclang-linker", "-mexec-model=reactor",
    "-Xlinker", "--export-if-defined=__main_argc_argv",
  ]),
]

let package = Package(
  name: "Guest",
  targets: [
    .target(
      name: "externref",
    ),
    .executableTarget(
      name: "RefsTest",
      dependencies: ["externref"],
      linkerSettings: linkerSettings,
    ),
  ]
)
