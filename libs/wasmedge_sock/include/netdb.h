#pragma once
// Based on https://github.com/hangedfish/wasmedge_wasi_socket_c

#include <netinet/in.h>

struct addrinfo {
	int ai_flags;
	int ai_family;
	int ai_socktype;
	int ai_protocol;
	socklen_t ai_addrlen;
	struct sockaddr *ai_addr;
	char *ai_canonname;
    int ai_canonnamelen;
	struct addrinfo *ai_next;
};

#define AI_PASSIVE      0x00
#define AI_CANONNAME    0x01
#define AI_NUMERICHOST  0x02
#define AI_NUMERICSERV  0x03
#define AI_V4MAPPED     0x04
#define AI_ALL          0x05
#define AI_ADDRCONFIG   0x06


#define NI_NUMERICHOST  0x01
#define NI_NUMERICSERV  0x02
#define NI_NOFQDN       0x04
#define NI_NAMEREQD     0x08
#define NI_DGRAM        0x10
#define NI_NUMERICSCOPE 0x100

#define EAI_BADFLAGS   -1
#define EAI_NONAME     -2
#define EAI_AGAIN      -3
#define EAI_FAIL       -4
#define EAI_FAMILY     -6
#define EAI_SOCKTYPE   -7
#define EAI_SERVICE    -8
#define EAI_MEMORY     -10
#define EAI_SYSTEM     -11
#define EAI_OVERFLOW   -12

#define EAI_NODATA     -5
#define EAI_ADDRFAMILY -9
#define EAI_INPROGRESS -100
#define EAI_CANCELED   -101
#define EAI_NOTCANCELED -102
#define EAI_ALLDONE    -103
#define EAI_INTR       -104
#define EAI_IDN_ENCODE -105
#define NI_MAXHOST 255
#define NI_MAXSERV 32



#ifdef __cplusplus
extern "C" {
#endif

struct servent {
	char *s_name;
	char **s_aliases;
	int s_port;
	char *s_proto;
};

struct hostent {
	char *h_name;
	char **h_aliases;
	int h_addrtype;
	int h_length;
	char **h_addr_list;
};
#define h_addr h_addr_list[0]

struct servent *getservbyname (const char *, const char *);

int getaddrinfo (const char *__restrict, const char *__restrict, const struct addrinfo *__restrict, struct addrinfo **__restrict);
void freeaddrinfo (struct addrinfo *);
int getnameinfo (const struct sockaddr *__restrict addr, socklen_t addrlen, char *__restrict host, socklen_t hostlen, char *__restrict serv, socklen_t servlen, int flags);

#ifdef __cplusplus
}
#endif