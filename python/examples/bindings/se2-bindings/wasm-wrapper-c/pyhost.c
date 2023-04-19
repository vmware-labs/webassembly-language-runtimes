#include "pyhost.h"

#include "sdk_module.h"

int pyhost_initialize(int argc)
{
    if (0 != init_sdk_module())
    {
        fprintf(stderr, "[pyhost.c]:Failed to register \"%s\" module for init.\n", SDK_MODULE);
        return -1;
    }

    Py_Initialize();
    return 0;
}

PyObject *pyhost_load_module(char *module_name)
{
    PyObject *pName = PyUnicode_DecodeFSDefault(module_name);
    /* Error checking of pName left out */

    PyObject *pModule = PyImport_Import(pName);
    Py_DECREF(pName);
    return pModule;
}
