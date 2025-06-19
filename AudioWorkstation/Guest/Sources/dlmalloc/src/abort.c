#include "malloc.h"

void abort(void) {
    __builtin_unreachable();
}
