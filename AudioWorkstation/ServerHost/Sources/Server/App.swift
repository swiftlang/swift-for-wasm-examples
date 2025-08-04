//===----------------------------------------------------------------------===//
//
// This source file is part of the Hummingbird open source project
//
// Copyright (c) 2024 Adam Fowler.
// Licensed under Apache License v2.0.
//
// See https://github.com/hummingbird-project/template/blob/main/LICENSE for license information
//
//===----------------------------------------------------------------------===//

import ArgumentParser
import Hummingbird
import Logging

@main
struct App: AsyncParsableCommand, AppArguments {
    @Option(name: .shortAndLong)
    var hostname: String = "127.0.0.1"

    @Option(name: .shortAndLong)
    var port: Int = 8080

    @Option(name: .shortAndLong)
    var logLevel: Logger.Level?

    func run() async throws {
        let app = try await buildApplication(self)
        try await app.runService()
    }
}

/// Extend `Logger.Level` so it can be used as an argument
#if hasFeature(RetroactiveAttribute)
    extension Logger.Level: @retroactive ExpressibleByArgument {}
#else
    extension Logger.Level: ExpressibleByArgument {}
#endif
