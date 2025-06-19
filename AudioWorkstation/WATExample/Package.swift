// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "WasmHost",
    platforms: [.macOS(.v14)],
    dependencies: [
        .package(url: "https://github.com/swiftwasm/WasmKit.git", from: "0.1.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .executableTarget(
            name: "WATExample",
            dependencies: [
                .product(name: "WAT", package: "WasmKit"),
                .product(name: "WasmKit", package: "WasmKit"),
            ]
        ),
    ]
)
