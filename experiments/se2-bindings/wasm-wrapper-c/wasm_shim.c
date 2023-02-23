#include "wasm_shim.h"

#include "pyhost.h"
#include "utils.h"

#include <string.h>
#include <stdlib.h>

#define __FILENAME__ (strrchr(__FILE__, '/') ? strrchr(__FILE__, '/') + 1 : __FILE__)

static PyObject *_plugin_module = NULL;

void _initialize()
{
    // Uncomment and look if python script cannot be found
    print_current_dir();
    // list_current_dir();

    if (_plugin_module != NULL)
    {
        fprintf(stderr, "Python module was already loaded!\n");
        exit(1);
    }

    pyhost_initialize(0);
    _plugin_module = pyhost_load_module("plugin");
}

u8 *allocate(i32 size)
{
    printf("\t%s | called allocate(%d)\n", __FILENAME__, size);
    return malloc(size);
}

void deallocate(u8 *pointer, i32 size)
{
    printf("\t%s | called deallocate(%p, %d)\n", __FILENAME__, pointer, size);
    return free(pointer);
}

void run_e(u8 *pointer, i32 size, i32 ident)
{
    printf("\t%s | id=%d | called run_e(%p, %d, %d).\n", __FILENAME__, ident, pointer, size, ident);
    if (_plugin_module == NULL)
    {
        fprintf(stderr, "\t%s | id=%d | run_e: plugin module was not loaded!\n", __FILENAME__, ident);
        exit(1);
    }

    PyObject *pFunc = PyObject_GetAttrString(_plugin_module, "run_e");
    if (!pFunc || !PyCallable_Check(pFunc))
    {
        if (PyErr_Occurred())
            PyErr_Print();
        fprintf(stderr, "\t%s | id=%d | run_e: cannot find function \"%s\"!\n", __FILENAME__, ident, "run_e");
        Py_XDECREF(pFunc);
        return;
    }

    PyObject *pArgs = Py_BuildValue("s#i", pointer, size, ident);
    if (!pArgs)
    {
        if (PyErr_Occurred())
            PyErr_Print();
        fprintf(stderr, "\t%s | id=%d | run_e: failed to convert arguments pointer=%p, size=%d, ident=%d!\n",
                __FILENAME__, ident, pointer, size, ident);
        Py_XDECREF(pFunc);
        return;
    }

    PyObject *pValue = PyObject_CallObject(pFunc, pArgs);
    if (pValue == NULL)
    {
        PyErr_Print();
        fprintf(stderr, "\t%s | id=%d | run_e: call to python function failed!\n", __FILENAME__, ident);
        Py_XDECREF(pArgs);
        Py_XDECREF(pFunc);
        return;
    }

    Py_XDECREF(pValue);
    Py_XDECREF(pArgs);
    Py_XDECREF(pFunc);

    fprintf(stderr, "\t%s | id=%d | run_e: completed.\n", __FILENAME__, ident);
}