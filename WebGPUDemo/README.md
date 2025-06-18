# WebGPU Example

Install a development snapshot and Swift SDK for Wasm by following
https://www.swift.org/documentation/articles/wasm-getting-started.html.

Build with the installed SDK using JavaScriptKit's `PackageToJSPlugin` plugin. Make sure to update
the Swift SDK to the installed version.
```
swift package --swift-sdk swift-DEVELOPMENT-SNAPSHOT-2025-06-03-a_wasm js --use-cdn
```

Start a HTTP server with eg. `python -m http.server` or `npx serve`. And then open
http://localhost:8000 to view the render of Swift using WebGPU.

> [!NOTE]
> If using an editor with SourceKit-LSP, make sure to update `.sourcekit-lsp/config.json` with the
> Swift SDK used in your build command.
