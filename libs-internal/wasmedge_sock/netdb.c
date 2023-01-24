// #include "include/netdb.h"

// #include "wasi_snapshot_preview1.h"

// #include <errno.h>

// int accept_instrumented(int fd, struct sockaddr *restrict addr, socklen_t *restrict len) {
//   int new_sockfd;
//   int res = __imported_wasmedge_wasi_snapshot_preview1_sock_accept(
//       fd, (uint32_t *)&new_sockfd);
//   if (res != 0) {
//     errno = res;
//     return -1;
//   }
//   return new_sockfd;
// }


// // // ------------------
// // #undef h_errno
// // int h_errno;

// // int *__h_errno_location(void)
// // {
// // 	return &h_errno;
// // }