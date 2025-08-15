// swift-tools-version: 6.2

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
      from: "0.33.1",
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
