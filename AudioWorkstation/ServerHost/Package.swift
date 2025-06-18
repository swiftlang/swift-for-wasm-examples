// swift-tools-version: 5.10
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
    name: "ServerHost",
    platforms: [.macOS(.v14)],
    dependencies: [
        .package(url: "https://github.com/apple/swift-nio.git", from: "2.72.0"),
        .package(url: "https://github.com/apple/swift-system.git", from: "1.3.2"),
        .package(url: "https://github.com/swiftwasm/WasmKit.git", from: "0.1.0"),
        .package(url: "https://github.com/hummingbird-project/hummingbird.git", from: "2.0.0"),
        .package(url: "https://github.com/apple/swift-argument-parser.git", from: "1.3.0")
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .executableTarget(
            name: "Server",
            dependencies: [
                .product(name: "_NIOFileSystem", package: "swift-nio"),
                .product(name: "SystemPackage", package: "swift-system"),
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
                .product(name: "Hummingbird", package: "hummingbird"),
                .product(name: "WasmKit", package: "WasmKit"),
            ]
        ),

        .testTarget(name: "ServerTests",
            dependencies: [
                .byName(name: "Server"),
                .product(name: "HummingbirdTesting", package: "hummingbird")
            ]
        )
    ]
)
