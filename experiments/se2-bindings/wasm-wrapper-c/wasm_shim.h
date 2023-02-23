#pragma once

#include <stdint.h>

#ifdef __wasi__

typedef uint8_t u8;
typedef uint16_t u16;
typedef uint32_t u32;
typedef uint64_t u64;

typedef int8_t i8;
typedef int16_t i16;
typedef int32_t i32;
typedef int64_t i64;

typedef float f32;
typedef double f64;

// __attribute__((export_name("_initialize")))
void _initialize();

// SubOrbital Plugin API
__attribute__((export_name("allocate"))) u8 *allocate(i32 size);
__attribute__((export_name("deallocate"))) void deallocate(u8 *pointer, i32 size);
__attribute__((export_name("run_e"))) void run_e(u8 *pointer, i32 size, i32 ident);

void env_return_result(u8 *result_pointer, i32 result_size, i32 ident)
    __attribute__((__import_module__("env"),
                   __import_name__("return_result")));
void env_return_error(i32 code, u8 *result_pointer, i32 result_size, i32 ident)
    __attribute__((__import_module__("env"),
                   __import_name__("return_error")));

#endif