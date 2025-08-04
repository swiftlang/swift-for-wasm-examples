#!/bin/sh

##===----------------------------------------------------------------------===##
##
## This source file is part of the Swift open source project
##
## Copyright (c) 2024 Apple Inc. and the Swift project authors
## Licensed under Apache License v2.0 with Runtime Library Exception
##
## See http://swift.org/LICENSE.txt for license information
## See http://swift.org/CONTRIBUTORS.txt for the list of Swift project authors
##
##===----------------------------------------------------------------------===##

set -eux

bin_path=$(swift build --triple wasm32-unknown-none-wasm -c release --show-bin-path)

swift build --triple wasm32-unknown-none-wasm -c release --product Plotter

for n in Bass HiHat Kick Mix; do
  swift build --triple wasm32-unknown-none-wasm -c release --product $n

  cp "${bin_path}/${n}.wasm" "$HOME"
done

