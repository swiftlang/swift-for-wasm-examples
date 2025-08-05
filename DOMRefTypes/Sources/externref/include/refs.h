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

#pragma once

#include <stddef.h>
#include <stdint.h>

#ifdef __cplusplus
extern "C" {
#endif /* __cplusplus */

typedef struct ExternRefIndex {
  int index;
} ExternRefIndex;

void freeExternRef(ExternRefIndex);

ExternRefIndex createElement(ExternRefIndex name);
ExternRefIndex getDocument(void);
ExternRefIndex getProp(ExternRefIndex self, ExternRefIndex name);
int getIntProp(ExternRefIndex self, ExternRefIndex name);
void setProp(ExternRefIndex self, ExternRefIndex name, ExternRefIndex val);
void appendChild(ExternRefIndex self, ExternRefIndex child);
ExternRefIndex bridgeString(const uint8_t *str, size_t bytes);
ExternRefIndex emptyArray(void);
void arrayPush(ExternRefIndex self, ExternRefIndex element);
ExternRefIndex fetchURL(ExternRefIndex url);

#ifdef __cplusplus
}
#endif /* __cplusplus */
