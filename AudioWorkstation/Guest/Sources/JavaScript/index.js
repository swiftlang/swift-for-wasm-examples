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

import { Encoder } from './encoder.js';

const decoder = new TextDecoder();
const loggerElement = document.getElementById('wasm-logger');
const moduleInstances = [];

function wasmMemoryAsString(i, address, byteCount) {
  return decoder.decode(moduleInstances[i].exports.memory.buffer.slice(address, address + byteCount));
}

function wasmMemoryAsFloat32Array(i, address, byteCount) {
  return new Float32Array(moduleInstances[i].exports.memory.buffer.slice(address, address + byteCount));
}

const contexts = [];

const canvasImports = {
  canvas: {
    beginPath: (i) => contexts[i].beginPath(),
    stroke: (i) => contexts[i].stroke(),
    moveTo: (i, x, y) => contexts[i].moveTo(x, y),
    lineTo: (i, x, y) => contexts[i].lineTo(x, y),
  },
}

const plotterModule = await WebAssembly.instantiateStreaming(
  fetch(".build/wasm32-unknown-none-wasm/release/plotter.wasm"),
  { ...canvasImports }
);

function encodeAndPlot(audioBuffer, context) {
  const wavEncoder = new Encoder(44100, 1);
  wavEncoder.encode([audioBuffer]);
  const blob = wavEncoder.finish();

  const audioURL = URL.createObjectURL(blob);
  document.getElementsByClassName('audio')[context].setAttribute('src', audioURL);

  const byteCount = audioBuffer.length * 4;
  const bufferPointer = plotterExports.allocateAudioBuffer(byteCount);
  const memoryBytes = new Float32Array(plotterExports.memory.buffer);
  memoryBytes.set(audioBuffer, bufferPointer / 4);
  plotterExports.plot(context, 1000, 200, 10, bufferPointer, byteCount);
  plotterExports.free(bufferPointer);
}

const plotterExports = plotterModule.instance.exports;

const audioImports = {
  audio: {
    encode: (i, address, byteCount) => {
      const audioBuffer = wasmMemoryAsFloat32Array(i, address, byteCount);

      encodeAndPlot(audioBuffer, i);
    },
  },
};

const consoleImports = {
  console: {
    log: (i, address, byteCount) => {
      loggerElement.innerHTML = wasmMemoryAsString(i, address, byteCount);
    },
    logInt: (x) => console.log(x),
    logFloat: (x) => console.log(x),
  }
};

const pluginElements = document.getElementsByClassName("plugin");

for (let i = 0; i < pluginElements.length; ++i) {
  const element = pluginElements[i];
  const canvasElement = element.getElementsByClassName("plotter")[0];
  const canvasContext = canvasElement.getContext('2d');
  canvasContext.strokeStyle = 'white';

  contexts.push(canvasContext);

  const { instance } = await WebAssembly.instantiateStreaming(
    fetch(element.dataset.modulePath),
    { ...audioImports, ...consoleImports }
  );

  moduleInstances.push(instance);

  instance.exports.main(i);
}

const mixElement = document.getElementById("tracks-mix");

if (mixElement) {
  const canvasElement = mixElement.getElementsByClassName("plotter")[0];
  const canvasContext = canvasElement.getContext('2d');
  canvasContext.strokeStyle = 'white';

  contexts.push(canvasContext);

  const response = await fetch("/mix");
  const responseBlob = await response.blob();

  const audioBuffer = new Float32Array(await responseBlob.arrayBuffer());

  encodeAndPlot(audioBuffer, contexts.length - 1);
}
