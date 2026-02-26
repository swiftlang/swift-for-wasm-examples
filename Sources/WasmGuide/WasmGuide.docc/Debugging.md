# Debugging

Debugging is a crucial part of the development process. With official toolchains providing more integrated tools, debugging WebAssembly modules has become more streamlined.

These tools are DWARF-based, so ensure you build your application with debug information enabled (which is the default for `swift build`).

## LLDB and WasmKit

For Swift `main` development snapshots, the toolchain includes enhanced support for debugging WebAssembly. The toolchain bundles `WasmKit`, a runtime that can execute Wasm modules, and an LLDB with WebAssembly support.

`WasmKit` provides debugging capabilities through the GDB Remote Protocol. This allows you to use the version of LLDB bundled with the `main` snapshot toolchain to connect to a running `WasmKit` process for in-depth, command-line debugging.

When using the [Swift extension for VS Code](https://marketplace.visualstudio.com/items?itemName=swiftlang.swift-vscode) with a `main` snapshot toolchain, you can get a more integrated experience:

- **Step through code:** Set breakpoints and step through your Swift code directly within the IDE.
- **Inspect state:** View variables, backtraces, and the current state of your application.

## Debugging in JavaScript environments

If you're debugging a WebAssembly app that runs in JavaScript environments (browsers or Node.js), please refer to the [JavaScriptKit Debugging documentation](https://swiftpackageindex.com/swiftwasm/javascriptkit/documentation/javascriptkit/debugging) for detailed information on how to use browser developer tools and other JS-specific debugging utilities.
