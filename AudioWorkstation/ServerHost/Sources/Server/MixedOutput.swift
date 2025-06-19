//===----------------------------------------------------------------------===//
//
// This source file is part of the Swift open source project
//
// Copyright (c) 2024 Apple Inc. and the Swift project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See http://swift.org/LICENSE.txt for license information
// See http://swift.org/CONTRIBUTORS.txt for the list of Swift project authors
//
//===----------------------------------------------------------------------===//

import Hummingbird
import WasmKit

struct MixedOutput: ResponseGenerator {
    init(modules: [IndexPage.Module]) throws {
        self.modules = try modules.map {
            try parseWasm(filePath: $0.absolutePath)
        }
    }
    
    var modules: [Module]

    func response(from request: Request, context: some RequestContext) throws -> Response {
        var samples = [Float32]()

        let engine = Engine()
        let store = Store(engine: engine)
        var moduleInstances = [Instance]()

        // Instantiate each Wasm module
        for (moduleIndex, module) in modules.enumerated() {
            let encode = ExternalValue.function(.init(store: store, type: .init(
                parameters: [.i32, .i32, .i32]
            )) { caller, args in
                let start = args[1].i32
                let byteCount = args[2].i32

                // Read audio buffer from Wasm linear memory.
                moduleInstances[moduleIndex].exports[memory: "memory"]!.data[
                    Int(start)..<Int(start + byteCount)
                ].withUnsafeBytes {
                    // Rebind memory bytes to `Float`.
                    $0.withMemoryRebound(to: Float.self) {
                        // Enumerate each floating point sample
                        for (i, sample) in $0.enumerated() {
                            // Extend `samples` buffer if needed.
                            if samples.count < $0.count {
                                // 0.0 (no signal) is the default sample.
                                samples.append(0.0)
                            }

                            // Mix current sample with an existing value.
                            samples[i] += sample
                        }

                        assert(samples.count == $0.count)
                    }
                }

                return []
            })

            let imports: Imports = [
                "audio": [ "encode": encode ]
            ]
            let instance = try module.instantiate(store: store, imports: imports)
            moduleInstances.append(instance)

            // Call entrypoint module function

            let main = instance.exports[function: "main"]!
            try main([.i32(0)])
        }

        var body = ByteBuffer()
        samples.withUnsafeBytes {
            _ = body.writeBytes($0)
        }

        return Response(status: .ok, body: .init(byteBuffer: body))
    }
}
