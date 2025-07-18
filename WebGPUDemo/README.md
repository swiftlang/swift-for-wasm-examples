# WebGPU Example

Install Swift 6.2 development snapshot and Swift SDK for Wasm by following
https://www.swift.org/documentation/articles/wasm-getting-started.html.

Build with the installed Swift SDK using JavaScriptKit's `PackageToJSPlugin` plugin. Make sure to update
the Swift SDK in the following command to the version that matches your installed swift.org toolchain.
```
swift package --swift-sdk swift-6.2-DEVELOPMENT-SNAPSHOT-2025-06-17-a_wasm js --use-cdn
```

WebGPU is enabled by default in beta and technical preview versions of Safari. Safari 17 and 18 require enabling
WebGPU feature flag as shown on the screenshot:

<img width="833" alt="Safari Feature Flags settings tab with WebGPU enabled" src="https://github.com/user-attachments/assets/7d0453ab-da51-4a6e-85da-dc466cf775be" />

See [the WebGPU Implementation Status page](https://github.com/gpuweb/gpuweb/wiki/Implementation-Status) for information about compatibility with other browsers.

Start an HTTP server that hosts the Wasm binary and other assets included in the project, e.g. you can use `python3 -m http.server` or `npx serve`, then open
http://localhost:8000 for `python3` or http://localhost:3000 for `npx serve` to view the Swift logo rendered using WebGPU.

> [!NOTE]
> When using an editor with SourceKit-LSP, update `.sourcekit-lsp/config.json` with the
> Swift SDK used in your build command.
