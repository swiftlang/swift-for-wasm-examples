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

import JavaScriptKit

// The static Swift type that the parsed JSON object's fields map onto. Each `@JSGetter`
// reads a property off the underlying JavaScript object as a statically typed Swift value.
@JSClass
struct User {
  @JSGetter var name: String
  // JSON has no integer type — every JSON number is a JavaScript `Number`, i.e. a `Double`.
  @JSGetter var age: Double
  // A JSON `null`, or a property absent from the object, maps to Swift `nil`.
  @JSGetter var nickname: Optional<String>
}
@JSClass(from: .global)
struct JSON {
  @JSFunction static func parse(_ text: String) throws(JSException) -> User
}

private func describe(_ user: User) throws(JSException) -> String {
  "name=\(try user.name), age=\(Int(try user.age)), nickname=\(try user.nickname ?? "<none>")"
}

// Exported to JavaScript as `exports.run()`. Parses three JSON strings and maps each onto the
// static `User` type: a `null` nickname, a present nickname, and a fixture that omits the
// nickname entirely while carrying a fractional `age` (truncated by the `Int(...)` narrowing).
@JS public func run() throws(JSException) -> String {
  let nullNickname = try JSON.parse(#"{"name":"Ada","age":36,"nickname":null}"#)
  let presentNickname = try JSON.parse(#"{"name":"Tim","age":48,"nickname":"Spark"}"#)
  let missingNickname = try JSON.parse(#"{"name":"Bo","age":29.5}"#)
  return try [
    describe(nullNickname),
    describe(presentNickname),
    describe(missingNickname),
  ].joined(separator: "\n")
}
