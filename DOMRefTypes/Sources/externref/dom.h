#pragma once

#include <stdint.h>

__attribute__((import_module("js")))
__attribute__((import_name("getDocument"))) __externref_t
getDocumentJS(void);

__attribute__((import_module("js")))
__attribute__((import_name("emptyDictionary"))) __externref_t
emptyDictionaryJS(void);

__attribute__((import_module("js")))
__attribute__((import_name("emptyArray"))) __externref_t
emptyArrayJS(void);

__attribute__((import_module("js")))
__attribute__((import_name("arrayPush"))) void
arrayPushJS(__externref_t self, __externref_t element);

__attribute__((import_module("js")))
__attribute__((import_name("bridgeString"))) __externref_t
bridgeStringJS(const uint8_t *str, uint32_t bytes);

__attribute__((import_module("js")))
__attribute__((import_name("setProp"))) void
setPropJS(__externref_t self, __externref_t name, __externref_t val);

__attribute__((import_module("js")))
__attribute__((import_name("getProp"))) __externref_t
getPropJS(__externref_t self, __externref_t name);


__attribute__((import_module("js")))
__attribute__((import_name("getIntProp"))) int
getIntPropJS(__externref_t self, __externref_t name);

__attribute__((import_module("document")))
__attribute__((import_name("createElement"))) __externref_t
createElementJS(__externref_t name);

__attribute__((import_module("document")))
__attribute__((import_name("appendChild"))) void
appendChildJS(__externref_t self, __externref_t child);
