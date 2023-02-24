#pragma once

void print_current_dir();
void list_current_dir();

#define LOG_PREFIX "\033[32m  [%s]\033[0m | "

#define LOG_MSG(fname, fmt, ...) \
    fprintf(stdout, LOG_PREFIX fmt "\n", fname __VA_OPT__(, ) __VA_ARGS__)
