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
        LOG_MSG(__FILENAME__, "Python module was already loaded!");
        exit(1);
    }

    pyhost_initialize(0);
    _plugin_module = pyhost_load_module("plugin");
}

u8 *allocate(i32 size)
{
    LOG_MSG(__FILENAME__, "Called allocate(%d)", size);
    u8 *result = malloc(size);
    LOG_MSG(__FILENAME__, "allocate(%d) returning %p", size, result);
    return result;
}

void deallocate(u8 *pointer, i32 size)
{
    LOG_MSG(__FILENAME__, "Called deallocate(%p, %d)", pointer, size);
    return free(pointer);
}

void run_e(u8 *pointer, i32 size, i32 ident)
{
    LOG_MSG(__FILENAME__, "id=%d | Called run_e(%p, %d, %d)", ident, pointer, size, ident);
    if (_plugin_module == NULL)
    {
        LOG_MSG(__FILENAME__, "id=%d | run_e: plugin module was not loaded!", ident);
        exit(1);
    }

    PyObject *pFunc = PyObject_GetAttrString(_plugin_module, "run_e");
    if (!pFunc || !PyCallable_Check(pFunc))
    {
        if (PyErr_Occurred())
            PyErr_Print();
        LOG_MSG(__FILENAME__, "id=%d | run_e: cannot find function \"%s\"!", ident, "run_e");
        Py_XDECREF(pFunc);
        return;
    }

    PyObject *pArgs = Py_BuildValue("s#i", pointer, size, ident);
    if (!pArgs)
    {
        if (PyErr_Occurred())
            PyErr_Print();
        LOG_MSG(__FILENAME__, "id=%d | run_e: failed to convert arguments pointer=%p, size=%d, ident=%d!",
                ident, pointer, size, ident);
        Py_XDECREF(pFunc);
        return;
    }

    LOG_MSG(__FILENAME__, "id=%d | Calling CPython plugin.run_e(\"%.*s\", %d)", ident, size, (char *)pointer, ident);
    PyObject *pValue = PyObject_CallObject(pFunc, pArgs);
    if (pValue == NULL)
    {
        PyErr_Print();
        LOG_MSG(__FILENAME__, "id=%d | run_e: call to python function failed!", ident);
        Py_XDECREF(pArgs);
        Py_XDECREF(pFunc);
        return;
    }

    Py_XDECREF(pValue);
    Py_XDECREF(pArgs);
    Py_XDECREF(pFunc);

    LOG_MSG(__FILENAME__, "id=%d | run_e: completed", ident);
}