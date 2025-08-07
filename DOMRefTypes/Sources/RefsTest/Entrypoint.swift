//===----------------------------------------------------------------------===//
//
// This source file is part of the Swift open source project
//
// Copyright (c) 2024-2025 Apple Inc. and the Swift project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
// See https://swift.org/CONTRIBUTORS.txt for the list of Swift project authors
//
//===----------------------------------------------------------------------===//

@main
struct Entrypoint {
  static func main() {
    var h1 = Document.global.createElement(name: JSString("h1"))
    let body = Document.global.body
    body.append(child: h1)
    h1.innerHTML = JSString("Hello, world!")
  }
}
