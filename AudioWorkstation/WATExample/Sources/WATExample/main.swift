import Foundation
import WasmKit
import WAT

// Compute WAT file path.
let watURL = URL(fileURLWithPath: #filePath)
    .deletingLastPathComponent()
    .deletingLastPathComponent()
    .deletingLastPathComponent()
    .appendingPathComponent("factorial.wat")

// Parse from WAT to binary Wasm module.
let binaryModule = try wat2wasm(String(decoding: Data(contentsOf: watURL), as: UTF8.self))

// Parse as WasmKit IR.
let parsedModule = try parseWasm(bytes: binaryModule)

let engine = Engine()
let store = Store(engine: engine)

// Initialize WasmKit runtime
let imports: Imports = [
    "host": [
        // Pass host printer function as a closure
        "print": ExternalValue.function(Function(store: store, type: .init(parameters: [.i32, .i32])) { caller, args in
                guard let start = args.first?.i32,
                      let offset = args.last?.i32
                else { return [] }

                // Decode linear memory
                let string = String(
                    decoding: caller.instance!.exports[memory: "memory"]!.data[Int(start) ..< Int(start + offset)],
                    as: UTF8.self
                )

                // Print the result
                print("Guest module printed: \(string)")
                return []
            }
        ),
    ]
]

// Instantiate the module
let moduleInstance = try parsedModule.instantiate(store: store, imports: imports)

// Call `main` function
let result = try moduleInstance.exports[function: "main"]!()
print("Returned value: \(result)")
