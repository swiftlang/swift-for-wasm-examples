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

let embeddedSwiftSettings: [SwiftSetting] = [
    .enableExperimentalFeature("Embedded"),
    .enableExperimentalFeature("Extern"),
    .interoperabilityMode(.Cxx),
    .unsafeFlags(["-wmo", "-disable-cmo", "-Xfrontend", "-gnone", "-Xfrontend", "-disable-stack-protector"]),
]

let embeddedCSettings: [CSetting] = [
    .unsafeFlags(["-fdeclspec"]),
]

let linkerSettings: [LinkerSetting] = [
    .unsafeFlags([
        "-Xclang-linker", "-nostdlib",
        "-Xlinker", "--no-entry",
    ]),
]

let libcSettings: [CSetting] = [
    .define("LACKS_TIME_H"),
    .define("LACKS_SYS_TYPES_H"),
    .define("LACKS_STDLIB_H"),
    .define("LACKS_STRING_H"),
    .define("LACKS_SYS_MMAN_H"),
    .define("LACKS_FCNTL_H"),
    .define("NO_MALLOC_STATS", to: "1"),
    .define("__wasilibc_unmodified_upstream"),
]

let package = Package(
    name: "Guest",
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .executableTarget(
            name: "Plotter",
            dependencies: ["dlmalloc"],
            cSettings: embeddedCSettings,
            swiftSettings: embeddedSwiftSettings,
            linkerSettings: linkerSettings
        ),
        .target(name: "VultDSP"),
        .target(
            name: "dlmalloc",
            cSettings: libcSettings
        ),
    ]
)

for module in ["Kick", "HiHat", "Bass", "Mix"] {
    package.targets.append(
        .executableTarget(
            name: module,
            dependencies: ["VultDSP", "dlmalloc"],
            cSettings: embeddedCSettings,
            swiftSettings: embeddedSwiftSettings,
            linkerSettings: linkerSettings
        )
    )
}
