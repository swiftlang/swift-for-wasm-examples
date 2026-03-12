# Porting code from other platforms

Make your code cross-platform and compatible with WebAssembly by checking for libraries and APIs
available for this platform.

In the currently standardized form widely supported by browsers and other hosts, WebAssembly
is a 32-bit architecture. You have to take this into account when porting code from other
platforms, since `Int` type is a signed 32-bit integer, and `UInt` is an unsigned 32-bit integer
when building with Wasm. You'll need to audit codepaths that cast 64-bit integers to `Int`
or `UInt`, and a good amount of cross-platform test coverage can help with that.

Additionally, there are differences in APIs exposed by the standard C library and Swift core
libraries which we discuss in the next few subsections.

## `WASILibc` module

When porting existing projects from other platforms to Wasm you might stumble upon code that
relies on importing a platform-specific [C
library](https://en.wikipedia.org/wiki/C_standard_library) module directly. It looks like `import
Glibc` on Linux, or `import Darwin` on Apple platforms. Fortunately, most of the standard C library
APIs are available when using Swift for Wasm, you just need to use `import WASILibc` to get access to it.
You will most likely want to preserve compatibility with other platforms, thus your imports would look
like this:

```swift
#if canImport(Darwin)
import Darwin
#elseif canImport(Glibc)
import Glibc
#elseif canImport(WASILibc)
import WASILibc
#endif
```

### Limitations

WebAssembly and [WASI](https://wasi.dev/) provide a constrained environment. Multi-threading, for example,
is an experimental feature and is only supported in development snapshots from the `main` branch. Please be aware of these limitations when
porting your code, which also has an impact on what can be supported in the Swift
Foundation library.

## Swift Foundation and Dispatch

[The Foundation core library](https://swift.org/core-libraries/#foundation) is available in
Wasm, but in a limited capacity. The main reason is that [the Dispatch core
library](https://swift.org/core-libraries/#libdispatch) is unavailable, as it relies heavily on multi-threading support
that is still experimental in Swift for WebAssembly. Many Foundation APIs rely on the presence of Dispatch under the hood. A few other types are unavailable in browsers
or aren't standardized in WASI hosts, such as support for sockets and low-level networking,
and they had to be disabled. These types are therefore absent in Foundation for Wasm:

| Type or module | Status |
|----------------|--------|
| `FoundationNetworking` | ❌ Unavailable |
| `FileManager` | ✅ Available after 6.0 |
| `Host` | ✅ Partially available after 6.0 |
| `Notification` | ✅ Available after 6.0 |
| `NotificationQueue` | ❌ Unavailable |
| `NSKeyedArchiver` | ✅ Available after 6.0 |
| `NSKeyedArchiverHelpers` | ✅ Available after 6.0 |
| `NSKeyedCoderOldStyleArray` | ✅ Available after 6.0 |
| `NSKeyedUnarchiver` | ✅ Available after 6.0 |
| `NSNotification` | ✅ Available after 6.0 |
| `NSSpecialValue` | ✅ Available after 6.0 |
| `Port` | ✅ Available after 6.0 |
| `PortMessage` | ✅ Available after 6.0 |
| `Process` | ❌ Unavailable. Consider using the new `Subprocess` library available in Swift 6.2. |
| `ProcessInfo` | ✅ Partially available after 5.7 |
| `PropertyListEncoder` | ✅ Available after 6.0 |
| `RunLoop` | ❌ Unavailable |
| `Stream` | ✅ Partially available after 6.0 |
| `SocketPort` | ❌ Unavailable |
| `Thread` | ✅ Available in `main` development snapshots |
| `Timer` | ❌ Unavailable |
| `UserDefaults` | ✅ Available after 6.0 |


## Swift Testing

The new [Swift Testing](https://developer.apple.com/documentation/testing) library is the recommended way
to write tests for your Wasm projects. All of its cross-platform APIs are available on WebAssembly, providing a modern and expressive way to validate your code.

## XCTest

[The swift-corelibs-xctest project](https://github.com/swiftlang/swift-corelibs-xctest) is available
on WebAssembly platforms, and you can use it to write tests for your Wasm projects.

The following XCTest features are unavailable when targeting Wasm:

| API | Status |
|----------------|--------|
| `XCTestExpectation` | ❌ Unavailable |
| `XCTNSPredicateExpectation` | ❌ Unavailable |
| `XCTNSNotificationExpectation` | ❌ Unavailable |
| `XCTWaiter` | ❌ Unavailable |
| `XCTest.perform` | ❌ Unavailable |
| `XCTest.run` | ❌ Unavailable |
