//===----------------------------------------------------------------------===//
//
// This source file is part of the Swift open source project
//
// Copyright (c) 2026 Apple Inc. and the Swift project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
// See https://swift.org/CONTRIBUTORS.txt for the list of Swift project authors
//
//===----------------------------------------------------------------------===//

import { init } from "./.build/plugins/PackageToJS/outputs/Package/index.js";

// `JSON` resolves from `globalThis` via the `from: .global` glue, so `getImports` is empty.
const { exports } = await init({ getImports: () => ({}) });

document.getElementById("result").textContent = exports.run();
