// swift-tools-version: 6.0
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

let package = Package(
    name: "Guest",
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .executableTarget(
            name: "Plotter",
            swiftSettings: [.enableExperimentalFeature("Extern")]
        ),
        .target(name: "VultDSP"),
    ]
)

for module in ["Kick", "HiHat", "Bass", "Mix"] {
    package.targets.append(
        .executableTarget(
            name: module,
            dependencies: ["VultDSP"],
            swiftSettings: [.interoperabilityMode(.Cxx), .enableExperimentalFeature("Extern")]
        )
    )
}
