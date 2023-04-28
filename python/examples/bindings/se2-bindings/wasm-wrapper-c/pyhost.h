#pragma once

#define PY_SSIZE_T_CLEAN
#include <Python.h>

int pyhost_initialize(int argc);

// Loads module (looking in PYTHONPATH)
PyObject *pyhost_load_module(char *module_name);
