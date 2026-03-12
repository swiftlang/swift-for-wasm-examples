# Multi-threading

While Swift Concurrency is available in Swift for WebAssembly out of the box, it is single-threaded by default. Read this article for special considerations relevant to multi-threading.

## Using threads in WebAssembly

While the WebAssembly spec defines [atomic operations](https://github.com/WebAssembly/threads),
it does not define a way to create threads. This means that WebAssembly modules can't create
threads themselves, and the host environment must provide a way to create threads and run
WebAssembly modules on them.

### [`wasi-threads`](https://github.com/WebAssembly/wasi-threads) proposal

The `wasi-threads` feature is only available in the `wasm32-unknown-wasip1-threads` target triple, which is explicitly distinct from the `wasm32-unknown-wasip1` target triple.

The `wasm32-unknown-wasip1-threads` target triple is only available in development snapshots of Swift SDK for WebAssembly.

You can run WebAssembly programs built with the `wasm32-unknown-wasip1-threads` target by using the WasmKit runtime via `swift run`, passing `--swift-sdk` option to it.

```console
# Install a Swift SDK that supports threads (replace URL with the latest available release from swift.org/install)
$ swift sdk install https://github.com/swiftwasm/swift/releases/download/swift-wasm-DEVELOPMENT-SNAPSHOT-YYYY-MM-DD-a/swift-wasm-DEVELOPMENT-SNAPSHOT-YYYY-MM-DD-a-wasm32-unknown-wasip1-threads.artifactbundle.zip --checksum <swift_sdk_checksum>

# Run using the installed Swift SDK
$ swift run --swift-sdk "$(swiftc -print-target-info | jq -r '.swiftCompilerTag')_wasm-threads"
```

### `WebWorkerTaskExecutor` - multi-threading in the browser

For browser use cases JavaScriptKit provides `WebWorkerTaskExecutor`, a [`TaskExecutor`](https://github.com/swiftlang/swift-evolution/blob/main/proposals/0417-task-executor-preference.md) implementation that runs tasks in a Web Worker. This allows you to run Swift code concurrently in a Web Worker sharing the same memory space.

This feature is available when you use the `wasm32-unknown-wasip1-threads` target and [`SharedArrayBuffer`](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/SharedArrayBuffer) for sharing Wasm linear memory between instantiated Wasm threads.

See more details in the following links:

- [Add `WebWorkerTaskExecutor` · Pull Request #256 · swiftwasm/JavaScriptKit](https://github.com/swiftwasm/JavaScriptKit/pull/256)
- [JavaScriptKit/Examples/Multithreading at main · swiftwasm/JavaScriptKit](https://github.com/swiftwasm/JavaScriptKit/tree/main/Examples/Multithreading)
- [WebWorkerTaskExecutor | Documentation](https://swiftpackageindex.com/swiftwasm/javascriptkit/main/documentation/javascripteventloop/webworkertaskexecutor)

