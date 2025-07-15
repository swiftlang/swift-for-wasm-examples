# Swift Audio Workstation

This example demonstrates support for WebAssembly in latest development snapshots of the Swift toolchain, in combination
with the [Embedded Swift mode](https://github.com/apple/swift/blob/main/docs/EmbeddedSwift/UserManual.md).
With foundational building blocks written in Swift, it utilizes C++ interop for calling into a
[DSP](https://en.wikipedia.org/wiki/Digital_signal_processing) library for synthesizing simple musical sequences. It is
written with a multi-platform approach, which makes it easy to integrate into Wasm-based serverless environment or
native applications and libraries.

It is split into three packages: `Guest` with Wasm modules built with Embedded Swift, `ServerHost` that embeds these modules, and `WATExample` that demonstrates compilation of WebAssembly Text Format to binary Wasm modules using Swift.

## Requirements

WebAssembly support in Swift is available for preview in Swift 6.2 development snapshots at
[swift.org/download](https://www.swift.org/download). Follow instructions on that page for installing `swiftly` and run `swiftly install 6.2-snapshot` after that.

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
