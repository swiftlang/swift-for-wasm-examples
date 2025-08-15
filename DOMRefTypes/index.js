//===----------------------------------------------------------------------===//
//
// This source file is part of the Swift open source project
//
// Copyright (c) 2024 Apple Inc. and the Swift project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
// See https://swift.org/CONTRIBUTORS.txt for the list of Swift project authors
//
//===----------------------------------------------------------------------===//


const decoder = new TextDecoder();

const moduleInstances = [];
function wasmMemoryAsString(i, address, byteCount) {
  return decoder.decode(moduleInstances[i].exports.memory.buffer.slice(address, address + byteCount));
}

function wasmMemoryAsFloat32Array(i, address, byteCount) {
  return new Float32Array(moduleInstances[i].exports.memory.buffer.slice(address, address + byteCount));
}

const importsObject = {
    js: {
      getDocument: () => document,
      emptyDictionary: () => { return {} },
      emptyArray: () => [],
      bridgeString: (address, count) => wasmMemoryAsString(0, address, count),
      setProp: (self, name, val) => { self[name] = val; },
      getProp: (self, name) => self[name],
      getIntProp: (self, name) => self[name],
    },

    document: {
      createElement: (name) => document.createElement(name),
      appendChild: (element, child) => element.appendChild(child),
    }
  };

const { instance, module } = await WebAssembly.instantiateStreaming(
  fetch(".build/release/RefsTest.wasm"),
  importsObject
);
moduleInstances.push(instance);

instance.exports.__main_argc_argv();
