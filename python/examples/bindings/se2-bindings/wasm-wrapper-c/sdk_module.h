#pragma once

// Simple python module that offers python-host functions
#define PY_SSIZE_T_CLEAN
#include <Python.h>

#define SDK_MODULE "sdk"

#define SDK_RETURN_RESULT "return_result"
#define SDK_RETURN_ERROR "return_error"

int init_sdk_module();
