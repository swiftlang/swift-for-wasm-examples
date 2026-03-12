# Troubleshooting

These are some common issues you may run into while using Swift with WebAssembly.

If you are having trouble that is not listed here, try searching for it on the [Swift Forums](https://forums.swift.org) or other community channels.

## `RuntimeError: memory access out of bounds`

If you encounter this error, there are a few possible causes:

### 1. Invalid memory access in your code
This can happen when using `UnsafePointer` or other unsafe constructs. Review your code for potential memory safety issues.

### 2. Incorrect WASI reactor initialization
If your Wasm module is intended to be used as a library (a "reactor"), it needs to be initialized correctly by the host.
Ensure your host environment calls the `_initialize` function if required by the WASI reactor ABI. See the [Exporting a function](<doc:ImportingExportingFunctions>) guide for an example.

### 3. Stack overflow
A stack overflow can trigger this error. You have a few options to address this:
- **Avoid deep recursion:** Refactor your code to use an iterative approach if possible.
- **Increase stack size:** You can increase the stack size via a linker option.
  ```bash
  swift build --swift-sdk <SDK_ID> -Xlinker -z -Xlinker stack-size=131072
  ```

## `fatal error: 'stdlib.h' file not found`

This error indicates that the compiler cannot find the necessary C standard library headers for the target platform. Ensure you are using the `--swift-sdk <SDK_ID>` flag with `swift build` to correctly configure the compiler for cross-compilation.

## `error: missing external dependency ...`

You may encounter this error if you are trying to invoke `swiftc` directly. The Swift SDK for WebAssembly currently requires you to build using the Swift Package Manager. Use the `swift build --swift-sdk <SDK_ID>` command instead.
