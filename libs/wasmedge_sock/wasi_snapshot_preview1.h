#include <stdint.h>

int32_t __imported_wasmedge_wasi_snapshot_preview1_sock_accept(uint32_t fd,
                                                               uint32_t *fd2)
    __attribute__((__import_module__("wasi_snapshot_preview1"),
                   __import_name__("sock_accept")));

