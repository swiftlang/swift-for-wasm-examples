# JSONBridge Example

Demonstrates how the result of JavaScript's `JSON.parse` is mapped onto a static Swift type
using [BridgeJS](https://swiftpackageindex.com/swiftwasm/JavaScriptKit/documentation/javascriptkit/introducing-bridgejs)
from JavaScriptKit, built with Embedded Swift for WebAssembly.

`Sources/JSONBridge/main.swift` declares a `@JSClass struct User` whose `@JSGetter` properties read
fields off a parsed JavaScript object as typed Swift values, and imports `globalThis.JSON.parse`
statically as a `@JSClass(from: .global)` namespace. `try JSON.parse(jsonString)` returns a `User`,
and `try user.name` / `try user.age` / `try user.nickname` read its fields with full Swift types and
no dynamic member lookup.

## Building

Install Swift and a matching Wasm embedded Swift SDK by following
["Getting Started with Swift SDKs for WebAssembly"](https://www.swift.org/documentation/articles/wasm-getting-started.html).
Update the Swift SDK name to match your installed toolchain (`swift sdk list`), then build with the
JavaScriptKit PackageToJS plugin:

```
# Latest 6.3 release:
swift package --swift-sdk swift-6.3.2-RELEASE_wasm-embedded js --use-cdn -c release

# Or a recent `main` development snapshot:
swift package --swift-sdk swift-DEVELOPMENT-SNAPSHOT-2026-05-27-a_wasm-embedded js --use-cdn -c release
```

## Running

Start an HTTP server in this directory and open it in a browser:

```
npx serve -l 8080
```

then open the printed URL (http://localhost:8080). The page renders:

```
name=Ada, age=36, nickname=<none>
name=Tim, age=48, nickname=Spark
name=Bo, age=29, nickname=<none>
```

