# WebGPU Example

Install a development snapshot and Swift SDK for Wasm by following
https://www.swift.org/documentation/articles/wasm-getting-started.html.

Build with the installed Swift SDK using JavaScriptKit's `PackageToJSPlugin` plugin. Make sure to update
the Swift SDK in the following command to the version that matches your installed swift.org toolchain.
```
swift package --swift-sdk swift-DEVELOPMENT-SNAPSHOT-2025-06-03-a_wasm js --use-cdn
```

WebGPU requires a beta or technical preview version of Safari. For recent release versions make sure to enable
WebGPU feature flag as shown on the screenshot:

<img width="833" alt="Safari Feature Flags settings tab with WebGPU enabled" src="https://github.com/user-attachments/assets/7d0453ab-da51-4a6e-85da-dc466cf775be" />

See [the WebGPU Implementation Status page](https://github.com/gpuweb/gpuweb/wiki/Implementation-Status) for information about compatibility with other browsers.

Start a HTTP server with eg. `python3 -m http.server` or `npx serve`, then open
http://localhost:8000 for `python3` or http://localhost:3000 for `npx serve` to view the Swift logo rendered using WebGPU.

> [!NOTE]
> If using an editor with SourceKit-LSP, make sure to update `.sourcekit-lsp/config.json` with the
> Swift SDK used in your build command.
