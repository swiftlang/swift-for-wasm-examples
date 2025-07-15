# Swift Audio Workstation

This example demonstrates support for WebAssembly in latest development snapshots of the Swift toolchain, in combination
with the [Embedded Swift mode](https://github.com/apple/swift/blob/main/docs/EmbeddedSwift/UserManual.md).
With foundational building blocks written in Swift, it utilizes C++ interop for calling into a
[DSP](https://en.wikipedia.org/wiki/Digital_signal_processing) library for synthesizing simple musical sequences. It is
written with a multi-platform approach, which makes it easy to integrate into Wasm-based serverless environment or
native applications and libraries.

It is split into three packages: `Guest` with Wasm modules built with Embedded Swift, `ServerHost` that embeds these modules, and `WATExample` that demonstrates compilation of WebAssembly Text Format to binary Wasm modules using Swift.

## Requirements

WebAssembly support in Swift is available for preview in latest Trunk Development (main) snapshots at
[swift.org/download](https://www.swift.org/download).

### macOS

1. Install [Xcode](https://apps.apple.com/us/app/xcode/id497799835?mt=12).
2. Verify selected Xcode path by running `xcode-select -p` in the terminal. If the incorrect Xcode is selected, follow
the steps provided in ["How do I select the default version of Xcode"](https://developer.apple.com/library/archive/technotes/tn2339/_index.html#//apple_ref/doc/uid/DTS40014588-CH1-HOW_DO_I_SELECT_THE_DEFAULT_VERSION_OF_XCODE_TO_USE_FOR_MY_COMMAND_LINE_TOOLS_) section of
["Building from the Command Line with Xcode FAQ"](https://developer.apple.com/library/archive/technotes/tn2339/_index.html).
3. Download latest `main` development snapshot, you can use [`DEVELOPMENT-SNAPSHOT-2024-04-01-a`](https://download.swift.org/development/xcode/swift-DEVELOPMENT-SNAPSHOT-2024-04-01-a/swift-DEVELOPMENT-SNAPSHOT-2024-04-01-a-osx.pkg) or a later version.
4. Run the downloaded installer. Select "Install for me only" option during installation.
5. Select the newly installed snapshot in terminal:

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
above, first build the package:

```sh
cd Guest
./build.sh
```

The script above will build Wasm audio plugins and copy resulting `.wasm` files to the user home directory.

Then start the HTTP server:

```sh
cd ../ServerHost
swift run Server
```

Open http://localhost:8080 in your browser to see the web page, where you can load audio plugins built with the `build.sh` script in the previous step.

## License

Copyright 2024 Apple Inc. and the Swift project authors. Licensed under Apache License v2.0 with Runtime Library Exception.

See [https://swift.org/LICENSE.txt](https://swift.org/LICENSE.txt) for license information.

See [https://swift.org/CONTRIBUTORS.txt](https://swift.org/CONTRIBUTORS.txt) for Swift project authors.

See [`LICENSE-vendored.md`](https://github.com/swiftlang/swift-for-wasm-examples/blob/main/AudioWorkstation/LICENSE-vendored.md) for exact licenses of code vendored in this repository. Specifically:

* Code in `Guest/Sources/dlmalloc` directory is derived from wasi-libc: https://github.com/WebAssembly/wasi-libc

> wasi-libc as a whole is multi-licensed under the Apache License v2.0 with LLVM Exceptions, the Apache License v2.0, and the MIT License. See the LICENSE-APACHE-LLVM, LICENSE-APACHE and LICENSE-MIT files, respectively, for details.
>
> Portions of this software are derived from third-party works covered by their own licenses:
>
> dlmalloc/ - CC0; see the notice in malloc.c for details emmalloc/ - MIT; see the notice in emmalloc.c for details libc-bottom-half/cloudlibc/ - BSD-2-Clause; see the LICENSE file for details libc-top-half/musl/ - MIT; see the COPYRIGHT file for details
>
> wasi-libc's changes to these files are multi-licensed under the Apache License v2.0 with LLVM Exceptions, the Apache License v2.0, the MIT License, and the original licenses of the third-party works.

* .wav format encoding implementation is derived from WavAudioEncoder.js library https://github.com/higuma/wav-audio-encoder-js and is licensed as following:

> The MIT License (MIT)
>
> Copyright (c) 2015 Yuji Miyane

* Code in `Guest/Sources/VultDSP` directory is derived from https://github.com/vult-dsp/vult and is licensed as following:

> MIT License
>
> Copyright (c) 2017 Leonardo Laguna Ruiz

* Web server starter template code is derived from [the Hummingbird template package](https://github.com/hummingbird-project/template) and is licensed as following:

> Copyright (c) 2024 Adam Fowler.
> Licensed under Apache License v2.0.
>
> See https://github.com/hummingbird-project/template/blob/main/LICENSE for license information
