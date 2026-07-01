# ``WasmGuide``

Run Swift in the browser and beyond: interoperate with JavaScript, port existing code, and handle concurrency.

@Metadata {
    @DisplayName("Swift for WebAssembly")
}

For initial setup, building your first application, and editor configuration, please
refer to the official [Getting Started with Swift SDKs for WebAssembly](https://www.swift.org/documentation/articles/wasm-getting-started.html) article on Swift.org.

Once you have your environment set up, you can dive into the topics below to learn more about building powerful [WebAssembly](https://webassembly.org) applications with Swift.

## JavaScript Interoperability

Running Swift in the browser is a common use case for WebAssembly. When not using high-level libraries,
direct calls to JavaScript from Swift to [Web APIs](https://developer.mozilla.org/en-US/docs/Learn_web_development/Extensions/Client-side_APIs/Introduction)
or [DOM APIs](https://developer.mozilla.org/en-US/docs/Web/API/Document_Object_Model) may be necessary.

See the [JavaScriptKit documentation](https://swiftpackageindex.com/swiftwasm/JavaScriptKit/documentation/javascriptkit) for details on how to interact with JavaScript from Swift.

## Topics

- <doc:Porting>
- <doc:Testing>
- <doc:Concurrency>
- <doc:Debugging>
- <doc:Troubleshooting>
- <doc:ImportingExportingFunctions>
- <doc:Multithreading>
