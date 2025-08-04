#include "dom.h"
#include "refs.h"
#include <stdint.h>

static __externref_t table[0];

typedef __externref_t (*__funcref funcref_t)(__externref_t);
static funcref_t ftable[0];

static int nextAvailableTableIndex = 0;
static const int defaultTableGrowSize = 256;

void freeExternRef(ExternRefIndex ref) {
  __builtin_wasm_table_set(table, ref.index, __builtin_wasm_ref_null_extern());
}

ExternRefIndex tableAppend(__externref_t ref) {
  ExternRefIndex idx = { .index = nextAvailableTableIndex++ };

  if (idx.index >= __builtin_wasm_table_size(table)) {
    __builtin_wasm_table_grow(table, __builtin_wasm_ref_null_extern(), defaultTableGrowSize);
  }

  __builtin_wasm_table_set(table, idx.index, ref);

  return idx;
}

ExternRefIndex createElement(ExternRefIndex name) {
 return tableAppend(createElementJS(__builtin_wasm_table_get(table, name.index)));
}

ExternRefIndex getDocument() {
  return tableAppend(getDocumentJS());
}

ExternRefIndex getProp(ExternRefIndex self, ExternRefIndex name) {
  return tableAppend(getPropJS(__builtin_wasm_table_get(table, self.index), __builtin_wasm_table_get(table, name.index)));
}

int getIntProp(ExternRefIndex self, ExternRefIndex name) {
  return getIntPropJS(__builtin_wasm_table_get(table, self.index), __builtin_wasm_table_get(table, name.index));
}

void setProp(ExternRefIndex self, ExternRefIndex name, ExternRefIndex val) {
  setPropJS(__builtin_wasm_table_get(table, self.index), __builtin_wasm_table_get(table, name.index), __builtin_wasm_table_get(table, val.index));
}

void appendChild(ExternRefIndex self, ExternRefIndex child) {
  appendChildJS(__builtin_wasm_table_get(table, self.index), __builtin_wasm_table_get(table, child.index));
}

ExternRefIndex bridgeString(const uint8_t *str, size_t bytes) {
  return tableAppend(bridgeStringJS(str, bytes));
}

ExternRefIndex emptyArray() {
  return tableAppend(emptyArrayJS());
}

void arrayPush(ExternRefIndex self, ExternRefIndex element) {
  arrayPushJS(__builtin_wasm_table_get(table, self.index), __builtin_wasm_table_get(table, element.index));
}
