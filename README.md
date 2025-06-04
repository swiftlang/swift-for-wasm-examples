# Swift for WebAssembly Examples

A repository with a "Swift Audio Workstation" example built with Swift for WebAssembly running in the browser.

This example demonstrates support for WebAssembly in latest development snapshots of the Swift toolchain, in combination
with the [Embedded Swift mode](https://github.com/apple/swift/blob/main/docs/EmbeddedSwift/UserManual.md).
With foundational building blocks written in Swift, it utilizes C++ interop for calling into a
[DSP](https://en.wikipedia.org/wiki/Digital_signal_processing) library for synthesizing simple musical sequences. It is
written with a multi-platform approach, which makes it easy to integrate into Wasm-based serverless environment or
native applications and libraries.

The repository is split into three packages: `Guest` with Wasm modules built with Embedded Swift, `ServerHost` that embeds these modules, and `WATExample` that demonstrates compilation of WebAssembly Text Format to binary Wasm modules using Swift.

## Requirements

WebAssembly support in Swift is available for preview in latest Trunk Development (main) snapshots at
[swift.org/download](https://www.swift.org/download).

### macOS

1. Install [Xcode](https://apps.apple.com/us/app/xcode/id497799835?mt=12).
2. Verify selected Xcode path by running `xcode-select -p` in the terminal. If the incorrect Xcode is selected, follow
the steps provided in ["How do I select the default version of Xcode"](https://developer.apple.com/library/archive/technotes/tn2339/_index.html#//apple_ref/doc/uid/DTS40014588-CH1-HOW_DO_I_SELECT_THE_DEFAULT_VERSION_OF_XCODE_TO_USE_FOR_MY_COMMAND_LINE_TOOLS_) section of
["Building from the Command Line with Xcode FAQ"](https://developer.apple.com/library/archive/technotes/tn2339/_index.html).
3. Download latest `main` development snapshot, you can use [`DEVELOPMENT-SNAPSHOT-2024-04-01-a`](https://download.swift.org/development/xcode/swift-DEVELOPMENT-SNAPSHOT-2024-04-01-a/swift-DEVELOPMENT-SNAPSHOT-2024-04-01-a-osx.pkg) or a later version.
4. Run the downloaded installer:

```sh
installer -target CurrentUserHomeDirectory -pkg ~/Downloads/swift-DEVELOPMENT-SNAPSHOT-2024-04-01-a-osx.pkg
```
  
5. Select the newly installed snapshot:

```sh
export TOOLCHAINS=$(plutil -extract CFBundleIdentifier raw \
  ~/Library/Developer/Toolchains/swift-latest.xctoolchain/Info.plist)
```

### Linux

Follow Linux-specific instructions provided on [swift.org/install](https://www.swift.org/install/#linux) to install the
latest development toolchain for your specific distribution.

### Docker

1. Start a docker container in a clone of this repository using the nightly swiftlang Ubuntu image, with a `/root/build`
mount to the current directory:

```sh
docker run --rm -it -v $(pwd):/root/build swiftlang/swift:nightly-jammy /bin/bash
```

2. Navigate to the package directory within the container:

```sh
cd /root/build
```

## How to Build and Run

Assuming you're within the cloned repository and have the latest development snapshots selected per the instructions
above, build modules from the `Guest` package (this will copy `.wasm` modules to the home directory of the current user):

```sh
cd Guest; ./build.sh
```


Then build and start the HTTP server:

```sh
cd ../ServerHost; swift run Server
```

Open http://localhost:8080 in your browser to see the project running. Use the web interface to upload previously built
`Guest` modules from the home directory.

## Contributing to this example
Contributions to Swift are welcomed and encouraged! Please see the
[Contributing to Swift guide](https://swift.org/contributing/).

Before submitting the pull request, please make sure you have [tested your
 changes](https://github.com/apple/swift/blob/main/docs/ContinuousIntegration.md)
 and that they follow the Swift project [guidelines for contributing
 code](https://swift.org/contributing/#contributing-code).

To be a truly great community, [Swift.org](https://swift.org/) needs to welcome
developers from all walks of life, with different backgrounds, and with a wide
range of experience. A diverse and friendly community will have more great
ideas, more unique perspectives, and produce more great code. We will work
diligently to make the Swift community welcoming to everyone.

To give clarity of what is expected of our members, Swift has adopted the
code of conduct defined by the Contributor Covenant. This document is used
across many open source communities, and we think it articulates our values
well. For more, see the [Code of Conduct](https://swift.org/code-of-conduct/).

## License

See [https://swift.org/LICENSE.txt](https://swift.org/LICENSE.txt) for license information.

See [`LICENSE-vendored.md`](https://github.com/apple/swift-for-wasm-examples/blob/main/LICENSE-vendored.md) for exact licenses of code vendored in this repository.
