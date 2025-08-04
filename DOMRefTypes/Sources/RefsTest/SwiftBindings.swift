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

import externref

struct JSObject: ~Copyable {
  fileprivate let ref: ExternRefIndex

  deinit {
    freeExternRef(ref)
  }
}

struct JSArray: ~Copyable {
  private let ref: ExternRefIndex

  init() {
    self.ref = emptyArray()
  }

  func append(_ object: borrowing JSObject) {
    arrayPush(ref, object.ref)
  }
}

struct JSString: ~Copyable {
  fileprivate let ref: ExternRefIndex

  deinit {
    freeExternRef(self.ref)
  }
}

extension JSString {
  init(_ string: StaticString) {
    self.ref = bridgeString(string.utf8Start, string.utf8CodeUnitCount)
  }

}

struct HTMLElement: ~Copyable {
  fileprivate let ref: ExternRefIndex

  func append(child: borrowing HTMLElement) {
    appendChild(self.ref, child.ref)
  }

  static let innerHTMLName = JSString("innerHTML")

  var innerHTML: JSString {

    get {
      JSString(ref: getProp(self.ref, Self.innerHTMLName.ref))
    }

    set {
      setProp(self.ref, Self.innerHTMLName.ref, newValue.ref)
    }
  }
}

struct Document: ~Copyable {
  fileprivate let object: JSObject

  static let global = Document(object: JSObject(ref: getDocument()))

  static let bodyName = JSString("body")

  func createElement(name: borrowing JSString) -> HTMLElement {
    .init(ref: externref.createElement(name.ref))
  }

  var body: HTMLElement {
    HTMLElement(ref: getProp(self.object.ref, Self.bodyName.ref))
  }
}
