#define PY_SSIZE_T_CLEAN

#include "pyhost.h"
#include "utils.h"
#include "wasm_shim.h"

int main(int argc, char *argv[])
{
    _initialize();
    return 0;
}
