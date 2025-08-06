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

import Hummingbird
import HummingbirdTesting
import Logging
import XCTest

@testable import Server

final class AppTests: XCTestCase {
    struct TestArguments: AppArguments {
        let hostname = "127.0.0.1"
        let port = 0
        let logLevel: Logger.Level? = .trace
    }

    func testApp() async throws {
        let args = TestArguments()
        let app = try await buildApplication(args)
        try await app.test(.router) { client in
            try await client.execute(uri: "/health", method: .get) { response in
                XCTAssertEqual(response.status, .notFound)
            }
        }
    }
}
