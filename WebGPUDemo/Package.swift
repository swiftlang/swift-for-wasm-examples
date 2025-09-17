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
      revision: "0b785610d170a0cbb4777ea379cb7221fc82c401",
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
