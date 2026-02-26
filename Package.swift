// swift-tools-version: 6.0

import PackageDescription

let package = Package(
  name: "swift-for-wasm-examples",
  products: [
    .library(name: "WasmGuide", targets: ["WasmGuide"])
  ],
  dependencies: [
    .package(
      url: "https://github.com/swiftlang/swift-docc-plugin", from: "1.1.0")
  ],
  targets: [
    .target(name: "WasmGuide")
  ])
