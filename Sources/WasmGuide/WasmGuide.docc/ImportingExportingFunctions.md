# Importing and Exporting Functions

WebAssembly modules often need to interact with their host environment.
This guide demonstrates how to build a Swift guest module that both exports
functions to the host and imports functions from it, using `WasmKit` as the host application.

This process involves two Swift packages:
1.  **Guest**: The WebAssembly module running inside the virtual machine.
2.  **Host**: The application that loads and executes the guest module.

## 1. The Guest Module

First, create a Swift package for the guest module. This module will:
-   **Export** an `add` function that the host can call.
-   **Import** a `print_result` function from the host to display the result.

**`Package.swift` for the Guest:**
Enable the `Extern` experimental feature to use the `@_extern` attribute.
```swift
// swift-tools-version:6.2
import PackageDescription

let package = Package(
    name: "Guest",
    products: [
        .library(name: "Guest", targets: ["Guest"]),
    ],
    targets: [
        .target(
            name: "Guest",
            swiftSettings: [
                .enableExperimentalFeature("Extern")
            ]
        ),
    ]
)
```

**Source code for the Guest (`Sources/Guest/Guest.swift`):**

The imported function must be annotated with both `@_extern(c, ...)` and `@_extern(wasm, ...)`.
`@_extern(c, ...)` ensures the C calling convention is used, so the Wasm import has the expected
signature. `@_extern(wasm, ...)` declares it as a Wasm import from the host module.

In Swift 6.3 and later (including development snapshots), you can use the `@c` attribute ([SE-0495](https://github.com/swiftlang/swift-evolution/blob/main/proposals/0495-cdecl.md)) for the export:

```swift
// 1. Import a function from the host
@_extern(c, "print_result")
@_extern(wasm, module: "host", name: "print_result")
func print_result(_ value: Int32)

// 2. Export a function to the host
@_expose(wasm, "add_and_print")
@c
public func addAndPrint(_ lhs: Int32, _ rhs: Int32) -> Int32 {
    let result = lhs + rhs
    // Call the imported host function
    print_result(result)
    return result
}
```

On earlier Swift versions, use `@_cdecl` instead:

```swift
// 1. Import a function from the host
@_extern(c, "print_result")
@_extern(wasm, module: "host", name: "print_result")
func print_result(_ value: Int32)

// 2. Export a function to the host
@_expose(wasm, "add_and_print")
@_cdecl("add_and_print")
public func addAndPrint(_ lhs: Int32, _ rhs: Int32) -> Int32 {
    let result = lhs + rhs
    // Call the imported host function
    print_result(result)
    return result
}
```

## 2. Building the Guest

Compile the guest package using the Swift SDK for WebAssembly.

```bash
# In the root directory of your guest package
swift build --swift-sdk <YOUR_WASM_SDK_ID>
```
Swift Package Manager will produce a `.wasm` file at `.build/wasm32-unknown-wasi/debug/Guest.wasm`. Copy it to a known location:
```bash
cp .build/wasm32-unknown-wasi/debug/Guest.wasm guest.wasm
```

## 3. The Host Application (WasmKit)

Now, create the host application that will execute the guest module.

**`Package.swift` for the Host:**
Add `WasmKit` and `WasmKitWASI` as dependencies.

```swift
// swift-tools-version:6.2
import PackageDescription

let package = Package(
    name: "Host",
    platforms: [.macOS(.v14)],
    dependencies: [
        .package(url: "https://github.com/swiftwasm/WasmKit.git", from: "0.2.0"),
    ],
    targets: [
        .executableTarget(name: "Host", dependencies: [
            .product(name: "WasmKit", package: "WasmKit"),
            .product(name: "WasmKitWASI", package: "WasmKit"),
        ]),
    ]
)
```

**Source code for the Host (`Sources/Host/Host.swift`):**

```swift
import WasmKit
import WasmKitWASI
import Foundation

@main
struct Host {
    static func main() throws {
        let wasmBinary = try Data(contentsOf: URL(fileURLWithPath: "path/to/your/guest.wasm"))

        let engine = Engine()
        let store = Store(engine: engine)
        let module = try parseWasm(bytes: Array(wasmBinary))

        // 1. Define the host function to provide to the guest
        let printResult = Function(store: store, parameters: [.i32]) { _, args in
            let value = args[0]
            print("[Host] The result is: \(value)")
            return []
        }

        // 2. Set up WASI and instantiate the module
        var imports = Imports()
        let wasi = try WASIBridgeToHost()
        wasi.link(to: &imports, store: store)
        imports.define(module: "host", name: "print_result", printResult)

        let instance = try module.instantiate(store: store, imports: imports)

        // Initialize the reactor (library) instance
        try wasi.initialize(instance)

        // 3. Call the exported function from the guest
        let addAndPrint = instance.exports[function: "add_and_print"]!
        _ = try addAndPrint([.i32(42), .i32(3)])
    }
}
```

## 4. Running the Host

Run the host application to see the interaction in action.

```bash
# In the root directory of your host package
swift run
# Expected output: [Host] The result is: i32(45)
```
