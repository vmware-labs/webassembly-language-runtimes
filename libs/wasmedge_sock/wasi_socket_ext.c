// Based on https://github.com/hangedfish/wasmedge_wasi_socket_c

#include "include/wasi_socket_ext.h"

#include <errno.h>
#include <memory.h>
#include <netinet/in.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "include/netdb.h"

// #define WASMEDGE_SOCKET_DEBUG

#ifdef WASMEDGE_SOCKET_DEBUG
#define WSEDEBUG(fmt, ...) fprintf(stderr, fmt __VA_OPT__(, ) __VA_ARGS__)
#else
#define WSEDEBUG(fmt, ...)
#endif

// WasmEdge Socket API

#define kUnspec 0
#define kInet4 1
#define kInet6 2

typedef uint8_t address_family_t;

#define kAny 0
#define kDatagram 1
#define kStream 2

typedef uint8_t socket_type_t;

#define kIPProtoIP 0
#define kIPProtoTCP 1
#define kIPProtoUDP 2

typedef uint32_t ai_protocol_t;

#define kAiPassive 0
#define kAiCanonname 1
#define kAiNumericHost 2
#define kAiNumericServ = 4
#define kAiV4Mapped = 8
#define kAiAll = 16
#define kAiAddrConfig = 32

typedef uint16_t ai_flags_t;

typedef struct wasi_address {
  uint8_t *buf;
  uint32_t size;
} wasi_address_t;

typedef struct iovec_read {
  uint8_t *buf;
  uint32_t size;
} iovec_read_t;

typedef struct iovec_write {
  uint8_t *buf;
  uint32_t size;
} iovec_write_t;

typedef struct wasi_sockaddr {
  address_family_t family;
  uint32_t sa_data_len;
  uint8_t *sa_data;
} wasi_sockaddr_t;

typedef struct wasi_canonname_buff {
  char name[30];
} wasi_canonname_buff_t;

#pragma pack(push, 1)
typedef struct wasi_addrinfo {
  ai_flags_t ai_flags;
  address_family_t ai_family;
  socket_type_t ai_socktype;
  ai_protocol_t ai_protocol;
  uint32_t ai_addrlen;
  wasi_sockaddr_t *ai_addr;
  char *ai_canonname;
  uint32_t ai_canonnamelen;
  struct wasi_addrinfo *ai_next;
} wasi_addrinfo_t;
#pragma pack(pop)

typedef struct sockaddr_generic {
  union sa {
    struct sockaddr_in sin;
    struct sockaddr_in6 sin6;
  } sa;

} sa_t;

#define MAX_ADDRINFO_RES_LEN 10

int32_t __imported_wasmedge_wasi_snapshot_preview1_sock_open(
    uint8_t addr_family, uint8_t sock_type, int32_t *fd)
    __attribute__((__import_module__("wasi_snapshot_preview1"),
                   __import_name__("sock_open")));

int32_t __imported_wasmedge_wasi_snapshot_preview1_sock_bind(
    uint32_t fd, wasi_address_t *addr, uint32_t port)
    __attribute__((__import_module__("wasi_snapshot_preview1"),
                   __import_name__("sock_bind")));

uint32_t
__imported_wasmedge_wasi_snapshot_preview1_sock_listen(uint32_t fd,
                                                       uint32_t backlog)
    __attribute__((__import_module__("wasi_snapshot_preview1"),
                   __import_name__("sock_listen")));

int32_t __imported_wasmedge_wasi_snapshot_preview1_sock_accept(uint32_t fd,
                                                               uint32_t *fd2)
    __attribute__((__import_module__("wasi_snapshot_preview1"),
                   __import_name__("sock_accept")));

int32_t __imported_wasmedge_wasi_snapshot_preview1_sock_connect(
    uint32_t fd, wasi_address_t *addr, uint32_t port)
    __attribute__((__import_module__("wasi_snapshot_preview1"),
                   __import_name__("sock_connect")));

int32_t __imported_wasmedge_wasi_snapshot_preview1_sock_recv(
    uint32_t fd, iovec_read_t *buf, uint32_t buf_len, uint16_t flags,
    uint32_t *recv_len, uint32_t *oflags)
    __attribute__((__import_module__("wasi_snapshot_preview1"),
                   __import_name__("sock_recv")));

int32_t __imported_wasmedge_wasi_snapshot_preview1_sock_recv_from(
    uint32_t fd, iovec_read_t *buf, uint32_t buf_len, uint8_t *addr,
    uint32_t *addr_len, uint16_t flags)
    __attribute__((__import_module__("wasi_snapshot_preview1"),
                   __import_name__("sock_recv_from")));

int32_t __imported_wasmedge_wasi_snapshot_preview1_sock_send(uint32_t fd,
                                                             iovec_write_t buf,
                                                             uint32_t buf_len,
                                                             uint16_t flags,
                                                             uint32_t *send_len)
    __attribute__((__import_module__("wasi_snapshot_preview1"),
                   __import_name__("sock_send")));

int32_t __imported_wasmedge_wasi_snapshot_preview1_sock_send_to(
    uint32_t fd, uint8_t *buf, uint32_t buf_len, uint8_t *addr,
    uint32_t addr_len, uint16_t flags)
    __attribute__((__import_module__("wasi_snapshot_preview1"),
                   __import_name__("sock_send_to")));

int32_t __imported_wasmedge_wasi_snapshot_preview1_sock_shutdown(uint32_t fd,
                                                                 uint8_t flags)
    __attribute__((__import_module__("wasi_snapshot_preview1"),
                   __import_name__("sock_shutdown")));

int32_t __imported_wasmedge_wasi_snapshot_preview1_sock_getaddrinfo(
    uint8_t *node, uint32_t node_len, uint8_t *server, uint32_t server_len,
    wasi_addrinfo_t *hint, uint32_t *res, uint32_t max_len, uint32_t *res_len)
    __attribute__((__import_module__("wasi_snapshot_preview1"),
                   __import_name__("sock_getaddrinfo")));

int32_t __imported_wasmedge_wasi_snapshot_preview1_sock_getpeeraddr(
    uint32_t fd, wasi_address_t *addr, uint32_t *addr_type, uint32_t *port)
    __attribute__((__import_module__("wasi_snapshot_preview1"),
                   __import_name__("sock_getpeeraddr")));

int32_t __imported_wasmedge_wasi_snapshot_preview1_sock_getlocaladdr(
    uint32_t fd, wasi_address_t *addr, uint32_t *addr_type, uint32_t *port)
    __attribute__((__import_module__("wasi_snapshot_preview1"),
                   __import_name__("sock_getlocaladdr")));

int32_t __imported_wasmedge_wasi_snapshot_preview1_sock_getsockopt(
    uint32_t fd, int32_t level, int32_t name, int32_t *flag,
    uint32_t *flag_size)
    __attribute__((__import_module__("wasi_snapshot_preview1"),
                   __import_name__("sock_getsockopt")));

int32_t __imported_wasmedge_wasi_snapshot_preview1_sock_setsockopt(
    uint32_t fd, int32_t level, int32_t name, int32_t *flag,
    uint32_t *flag_size)
    __attribute__((__import_module__("wasi_snapshot_preview1"),
                   __import_name__("sock_setsockopt")));

int socket(int domain, int type, int protocol) {
  WSEDEBUG("WWSock| socket called: %d, %d, %d \n", domain, type, protocol);
  int fd;
  address_family_t af = (domain == AF_INET ? kInet4 : kInet6);
  socket_type_t st = (type == SOCK_STREAM ? kStream : kDatagram);
  int res = __imported_wasmedge_wasi_snapshot_preview1_sock_open(
      (int8_t)af, (int8_t)st, &fd);
  if (0 != res) {
    errno = res;
    printf("socket err: %s \n", strerror(errno));
    WSEDEBUG("WWSock| socket failed with error: %s \n", strerror(errno));
    return -1;
  }
  WSEDEBUG("WWSock| socket returning: %d \n", fd);
  return fd;
}

int bind(int fd, const struct sockaddr *addr, socklen_t len) {
  WSEDEBUG("WWSock| bind[%d]: calling bind on sa_data=[", __LINE__);
  for (int i = 0; i < len; ++i)
    WSEDEBUG("'%d', ", (short)addr->sa_data[i]);
  WSEDEBUG("]\n");

  wasi_address_t wasi_addr;
  memset(&wasi_addr, 0, sizeof(wasi_address_t));
  uint32_t port = 0;
  if (AF_INET == addr->sa_family) {
    struct sockaddr_in *sin = (struct sockaddr_in *)addr;
    wasi_addr.buf = (uint8_t *)&sin->sin_addr;
    wasi_addr.size = 4;
    port = sin->sin_port;
  } else if (AF_INET6 == addr->sa_family) {
    struct sockaddr_in6 *sin = (struct sockaddr_in6 *)addr;
    wasi_addr.buf = (uint8_t *)&sin->sin6_addr;
    wasi_addr.size = 16;
    port = sin->sin6_port;
  }

  WSEDEBUG("WWSock| bind[%d]: "
           "__imported_wasmedge_wasi_snapshot_preview1_sock_bind\n",
           __LINE__);
  int res = __imported_wasmedge_wasi_snapshot_preview1_sock_bind(fd, &wasi_addr,
                                                                 port);
  WSEDEBUG("WWSock| bind[%d]: res=%d\n", __LINE__, res);
  if (res != 0) {
    errno = res;
    return -1;
  }
  return res;
}

int connect(int fd, const struct sockaddr *addr, socklen_t len) {
  WSEDEBUG("WWSock| connect[%d]: fd=%d, addr=%d, port=%d \n", __LINE__, fd,
           ((struct sockaddr_in *)addr)->sin_addr.s_addr,
           ((struct sockaddr_in *)addr)->sin_port);
  wasi_address_t wasi_addr;
  memset(&wasi_addr, 0, sizeof(wasi_address_t));
  uint32_t port;
  if (AF_INET == addr->sa_family) {
    struct sockaddr_in *sin = (struct sockaddr_in *)addr;
    wasi_addr.buf = (uint8_t *)&sin->sin_addr;
    wasi_addr.size = 4;
    port = ntohs(sin->sin_port);
  } else if (AF_INET6 == addr->sa_family) {
    struct sockaddr_in6 *sin = (struct sockaddr_in6 *)addr;
    wasi_addr.buf = (uint8_t *)&sin->sin6_addr;
    wasi_addr.size = 16;
    port = ntohs(sin->sin6_port);
  } else {
    errno = EAFNOSUPPORT;
    return -1;
  }
  int res = __imported_wasmedge_wasi_snapshot_preview1_sock_connect(
      fd, &wasi_addr, port);
  if (res != 0) {
    errno = res;
    WSEDEBUG("WWSock| connect[%d]: fd=%d failed: wasi_error=%d, errno=%d \n",
             __LINE__, fd, res, errno);
    return -1;
  }
  return res;
}

int listen(int fd, int backlog) {
  WSEDEBUG(
      "WWSock| __imported_wasmedge_wasi_snapshot_preview1_sock_listen[%d]: \n",
      __LINE__);
  int res = __imported_wasmedge_wasi_snapshot_preview1_sock_listen(fd, backlog);
  WSEDEBUG("WWSock| listen[%d]: res=%d\n", __LINE__, res);
  return res;
}

int accept(int fd, struct sockaddr *restrict addr, socklen_t *restrict len) {
  WSEDEBUG("WWSock| accept[%d]: fd=%d\n", __LINE__, fd);
  int new_sockfd;
  int res = __imported_wasmedge_wasi_snapshot_preview1_sock_accept(
      fd, (uint32_t *)&new_sockfd);
  if (res != 0) {
    errno = res;
    WSEDEBUG("WWSock| accept[%d]: failed=%d\n", __LINE__, errno);
    return -1;
  }
  WSEDEBUG("WWSock| accept[%d]: client_fd=%d\n", __LINE__, new_sockfd);
  return new_sockfd;
}

int setsockopt(int fd, int level, int optname, const void *optval,
               socklen_t optlen) {
  WSEDEBUG("WWSock| setsockopt[%d]: fd=%d\n", __LINE__, fd);
  int res = __imported_wasmedge_wasi_snapshot_preview1_sock_setsockopt(
      fd, level, optname, (int32_t *)optval, (uint32_t *)&optlen);
  if (res != 0) {
    errno = res;
    return -1;
  }
  return 0;
}

struct servent *getservbyname(const char *name, const char *prots) {
  WSEDEBUG("WWSock| getservbyname[%d]: name=%s\n", __LINE__, name);
  return NULL;
}

static struct addrinfo *
convert_wasi_addrinfo_to_addrinfo(wasi_addrinfo_t *wasi_addrinfo,
                                  uint32_t size) {
  WSEDEBUG("WWSock| convert_wasi_addrinfo_to_addrinfo[%d]: \n", __LINE__);

  struct addrinfo *addrinfo_arr = (struct addrinfo *)calloc(
      (sizeof(struct addrinfo) + sizeof(struct sockaddr_generic)) * size + 30,
      1);
  struct sockaddr_generic *sockaddr_generic_arr =
      (struct sockaddr_generic *)&addrinfo_arr[size];
  char *ai_canonname = (char *)&sockaddr_generic_arr[size];
  int ai_canonnamelen = addrinfo_arr[0].ai_canonnamelen;
  memcpy(ai_canonname, addrinfo_arr[0].ai_canonname, ai_canonnamelen);

  for (size_t i = 0; i < size; i++) {
    addrinfo_arr[i] = (struct addrinfo){
        .ai_flags = (int)wasi_addrinfo[i].ai_flags,
        .ai_family = wasi_addrinfo[i].ai_family == kInet4 ? AF_INET : AF_INET6,
        .ai_socktype =
            wasi_addrinfo[i].ai_socktype == kStream ? SOCK_STREAM : SOCK_DGRAM,
        .ai_protocol = wasi_addrinfo[i].ai_protocol == kIPProtoTCP
                           ? IPPROTO_TCP
                           : IPPROTO_UDP,
        .ai_addrlen = 0,
        .ai_addr = (struct sockaddr *)&sockaddr_generic_arr[i],
        .ai_canonname = ai_canonname,
        .ai_canonnamelen = ai_canonnamelen,
        .ai_next = NULL,
    };
    if (wasi_addrinfo[i].ai_addr != NULL) {
      if (wasi_addrinfo[i].ai_addr->family == kInet4) {
        // IPv4
        wasi_addrinfo[i].ai_addrlen = sizeof(struct sockaddr_in);
        sockaddr_generic_arr[i].sa.sin.sin_family = AF_INET;
        sockaddr_generic_arr[i].sa.sin.sin_port =
            *(uint16_t *)&wasi_addrinfo[i].ai_addr->sa_data[0];
        sockaddr_generic_arr[i].sa.sin.sin_addr.s_addr =
            *(in_addr_t *)&wasi_addrinfo[i].ai_addr->sa_data[2];
      } else {
        // IPv6
        wasi_addrinfo[i].ai_addrlen = sizeof(struct sockaddr_in6);
        sockaddr_generic_arr[i].sa.sin6.sin6_family = AF_INET6;
        sockaddr_generic_arr[i].sa.sin6.sin6_port =
            *(uint16_t *)&wasi_addrinfo[i].ai_addr->sa_data[0];
        // WasmEdge rust socket api not support IPv6 addrinfo.
        WSEDEBUG("Not support IPv6 addrinfo.");
        abort();
      }
    }
    if (i > 0) {
      addrinfo_arr[i - 1].ai_next = &addrinfo_arr[i];
    }
  }
  return addrinfo_arr;
}

int getaddrinfo(const char *restrict host, const char *restrict serv,
                const struct addrinfo *restrict hint,
                struct addrinfo **restrict res) {
  WSEDEBUG("WWSock| getaddrinfo[%d]: \n", __LINE__);
  uint32_t res_len = 0;
  uint8_t *sockbuff = (uint8_t *)calloc(26 * MAX_ADDRINFO_RES_LEN, 1);
  wasi_sockaddr_t *sockaddr_arr =
      (wasi_sockaddr_t *)calloc(sizeof(wasi_sockaddr_t) * MAX_ADDRINFO_RES_LEN +
                                    sizeof(wasi_canonname_buff_t),
                                1);
  wasi_addrinfo_t *addrinfo_arr = (wasi_addrinfo_t *)calloc(
      sizeof(wasi_addrinfo_t) * MAX_ADDRINFO_RES_LEN, 1);
  for (size_t i = 0; i < MAX_ADDRINFO_RES_LEN; i++) {
    sockaddr_arr[i].sa_data = &sockbuff[i];
    addrinfo_arr[i].ai_addr = &sockaddr_arr[i];
    addrinfo_arr[i].ai_canonname = (char *)&addrinfo_arr[MAX_ADDRINFO_RES_LEN];
    if (i > 0) {
      addrinfo_arr[i - 1].ai_next = &addrinfo_arr[i];
    }
  }
  wasi_addrinfo_t wasi_hint = (wasi_addrinfo_t){
      .ai_flags = (ai_flags_t)hint->ai_flags,
      .ai_family = hint->ai_family == AF_INET6 ? kInet6 : kInet4,
      .ai_socktype = hint->ai_socktype == SOCK_DGRAM ? kDatagram : kStream,
      .ai_protocol =
          hint->ai_protocol == IPPROTO_UDP ? kIPProtoUDP : kIPProtoTCP,
      .ai_addrlen = 0,
      .ai_addr = NULL,
      .ai_canonname = NULL,
      .ai_canonnamelen = 0,
      .ai_next = NULL,
  };

  int rc = __imported_wasmedge_wasi_snapshot_preview1_sock_getaddrinfo(
      (uint8_t *)host, strlen(host), (uint8_t *)serv, strlen(serv), &wasi_hint,
      (uint32_t *)&addrinfo_arr, MAX_ADDRINFO_RES_LEN, &res_len);
  if (0 != rc) {
    errno = rc;
    free((void *)addrinfo_arr);
    free((void *)sockaddr_arr);
    free((void *)sockbuff);
    return -1;
  }
  *res = convert_wasi_addrinfo_to_addrinfo(addrinfo_arr, res_len);
  free(addrinfo_arr);
  free(sockaddr_arr);
  free(sockbuff);
  return 0;
}

void freeaddrinfo(struct addrinfo *p) {
  WSEDEBUG("WWSock| freeaddrinfo[%d]: \n", __LINE__);
  free(p);
}

int getnameinfo(const struct sockaddr *__restrict addr, socklen_t addrlen,
                char *__restrict host, socklen_t hostlen, char *__restrict serv,
                socklen_t servlen, int flags) {
  WSEDEBUG("WWSock| getnameinfo[%d]: \n", __LINE__);
  // When lookup fails, software should use the IP address string as hostname
  return EAI_FAIL;
}
