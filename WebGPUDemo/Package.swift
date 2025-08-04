// swift-tools-version: 6.1

import PackageDescription

let package = Package(
  name: "WebGPUDemo",
  dependencies: [
    .package(
      url: "https://github.com/swiftwasm/WebAPIKit.git",
      branch: "main",
    ),
    .package(
      url: "https://github.com/swiftwasm/JavaScriptKit.git",
      branch: "main",
    ),
  ],
  targets: [
    .executableTarget(
      name: "WebGPUDemo",
      dependencies: [
        .product(name: "JavaScriptKit", package: "JavaScriptKit"),
        .product(name: "JavaScriptEventLoop", package: "JavaScriptKit"),
        .product(name: "DOM", package: "WebAPIKit"),
        .product(name: "WebGPU", package: "WebAPIKit"),
      ],
    )
  ]
)
