#include <string.h>
#include <stdlib.h>
#include <stddef.h>
#include <fcntl.h>
#include <errno.h>
#include <unistd.h>
#include <sys/socket.h>
#include <arpa/inet.h>
#include <sys/select.h>
#include <sys/types.h>
#include <sys/un.h>
#include <syslog.h>
#include <curl/curl.h>
#include "vnc.h"

#ifdef DEBUG
#define syslog(LEVEL, ...) printf(__VA_ARGS__)
#endif

#define VNC_NSIZE 16
#define BUF_NSIZE 2048
#define TRYAGAIN(x) (x == EWOULDBLOCK || x == EAGAIN)
#define _max(x, y) ((x >= y) ? x : y)
#define _min(x, y) ((x <= y) ? x : y)

static const char ws_mask[] = "\x00\x00\x00\x00";
static const char ws_pong[] = "\x8a\x80\x0a\x0f\xa0\xf0";
static const char ws_close[] = "\x88\x82\x00\x00\x00\x00\x03\xe8";
static const int ws_ponglen = sizeof(ws_pong) - 1;
static const int ws_closelen = sizeof(ws_close) - 1;
static const char *fmt = "GET %s HTTP/1.1\r\nUpgrade: websocket\r\n"
        "Connection: Upgrade\r\nHost: %s\r\n"
        "Sec-WebSocket-Key: dGhlIHNhbXBsZSBub25jazz==\r\n"
        "Sec-WebSocket-Version: 13\r\n%s\r\n\r\n";

struct vnc_t
{
    CURL *curl[VNC_NSIZE];
    char *lobuf[VNC_NSIZE];
    char *cubuf[VNC_NSIZE];
    int losock[VNC_NSIZE];
    int cusock[VNC_NSIZE];
    short lonum[VNC_NSIZE];
    short cunum[VNC_NSIZE];
    uint64_t wsnum[VNC_NSIZE];
    int lisock;
    int fdmax;
    fd_set rdfds;
    fd_set wrfds;
};

struct cp_t
{
    char *host;
    char *end;
    char *rest;
    char *ip;
    int port;
};

static struct vnc_t *vnc_init()
{
    struct vnc_t* const vnc = (struct vnc_t*) malloc(sizeof(struct vnc_t));
    if (!vnc)
    {
        syslog(LOG_ERR, "vnc_init: %s\n", strerror(errno));
        return NULL;
    }

    memset(vnc, 0, sizeof(struct vnc_t));
    int sock = socket(AF_UNIX, SOCK_DGRAM, 0);
    if (sock == -1)
    {
        syslog(LOG_ERR, "vnc_init: %s\n", strerror(errno));
        return NULL;
    }

    struct sockaddr_un addr;
    remove(SPATH);
    addr.sun_family = AF_UNIX;
    strcpy(addr.sun_path, SPATH);
    if (bind(sock, (struct sockaddr*) &addr, sizeof(addr)) == -1)
    {
        syslog(LOG_ERR, "vnc_init bind: %s\n", strerror(errno));
        return 0;
    }

    fcntl(sock, F_SETFL, O_NONBLOCK);
    FD_SET(sock, &vnc->rdfds);
    vnc->lisock = vnc->fdmax = sock;
    curl_global_init(CURL_GLOBAL_ALL);

    return vnc;
}

static int ws_connect(CURL *curl, char *host, char *end, char *rest)
{
    syslog(LOG_INFO, "ws_conn: %s%s\n", host, end);
    const char *p = strchr(host, ':');
    if (!p)
    {
        errno = EINVAL;
        syslog(LOG_ERR, "ws_conn: %s\n", strerror(errno));
        return -1;
    }

#ifdef SR_SSL_CACERT
    curl_easy_setopt(curl, CURLOPT_CAINFO, SR_SSL_CACERT);
#endif
    curl_easy_setopt(curl, CURLOPT_URL, host);
    curl_easy_setopt(curl, CURLOPT_CONNECT_ONLY, 1);
#ifdef DEBUG
    curl_easy_setopt(curl, CURLOPT_VERBOSE, 1);
#endif

    CURLcode rc = curl_easy_perform(curl);
    if (rc != CURLE_OK)
    {
        syslog(LOG_ERR, "ws_conn: %s\n", curl_easy_strerror(rc));
        return -1;
    }
    curl_socket_t sock;
#ifdef CURLINFO_SOCKET
    rc = curl_easy_getinfo(curl, CURLINFO_ACTIVESOCKET, &sock);
#else
    rc = curl_easy_getinfo(curl, CURLINFO_LASTSOCKET, &sock);
#endif

    if (rc != CURLE_OK)
    {
        syslog(LOG_ERR, "ws_conn: %s\n", curl_easy_strerror(rc));
        return -1;
    }

    char buf[4096];
    size_t len = 0;
    len = snprintf(buf, sizeof(buf), fmt, end, p + 3, rest ? rest : "");
    size_t n = 0;

    while (n < len)
    {
        size_t i = 0;
        rc = curl_easy_send(curl, buf, len, &n);
        if (rc == CURLE_OK || rc == CURLE_AGAIN)
        {
            n += i;
        } else
        {
            syslog(LOG_ERR, "ws_conn: %s\n", curl_easy_strerror(rc));
            return -1;
        }
    }

    fd_set rdset;
    FD_ZERO(&rdset);
    FD_SET(sock, &rdset);
    struct timeval val =
    { 30, 0 };
    errno = 0;

    if (select(sock + 1, &rdset, NULL, NULL, &val) <= 0)
    {
        errno = errno ? errno : ETIME;
        syslog(LOG_ERR, "ws_conn select: %s\n", strerror(errno));
        return -1;
    }

    rc = curl_easy_recv(curl, buf, sizeof(buf), &n);
    if (n <= 0)
    {
        syslog(LOG_ERR, "ws_conn: %s\n", curl_easy_strerror(rc));
        return -1;
    }

    syslog(LOG_INFO, "ws_conn: OK!\n");

    return sock;
}

static int ts_connect(const char *ip, int port)
{
    syslog(LOG_INFO, "ts_conn: %s:%d\n", ip, port);
    struct sockaddr_in addr;
    struct sockaddr *addrp = (struct sockaddr*) &addr;

    const int sock = socket(AF_INET, SOCK_STREAM, 0);
    if (sock == -1)
    {
        syslog(LOG_ERR, "ts_conn: %s\n", strerror(errno));
        return -1;
    }

    memset(addrp, 0, sizeof(addr));
    addr.sin_family = AF_INET;
    addr.sin_addr.s_addr = inet_addr(ip);
    addr.sin_port = htons(port);

    if (connect(sock, addrp, sizeof(addr)) == -1)
    {
        syslog(LOG_ERR, "ts_conn: %s\n", strerror(errno));
        close(sock);
        return -1;
    }

    syslog(LOG_INFO, "ts_conn: OK!\n");
    fcntl(sock, F_SETFL, O_NONBLOCK);

    return sock;
}

static int find_fdmax(fd_set *rdp, fd_set *wrp, int fdmax)
{
    while (fdmax && !FD_ISSET(fdmax, rdp) && !FD_ISSET(fdmax, wrp))
    {
        --fdmax;
    }

    return fdmax;
}

static int vnc_connection_new(struct vnc_t *vnc, struct cp_t *cp)
{
    int i = 0, fd = 0, sock = 0;
    while (i < VNC_NSIZE && vnc->lobuf[i])
    {
        ++i;
    }

    if (i >= VNC_NSIZE)
    {
        errno = ERANGE;
        syslog(LOG_ERR, "vnc_new: %s\n", strerror(errno));
        return -1;
    }

    CURL *curl = curl_easy_init();
    if (!curl)
    {
        errno = ENOMEM;
        syslog(LOG_ERR, "vnc_new: %s\n", strerror(errno));
        return -1;
    }

    if ((fd = ws_connect(curl, cp->host, cp->end, cp->rest)) == -1)
    {
        curl_easy_cleanup(curl);
        return -1;
    }

    if ((sock = ts_connect(cp->ip, cp->port)) == -1)
    {
        curl_easy_cleanup(curl);
        return -1;
    }

    char *buf = (char*) malloc(2 * BUF_NSIZE);
    if (!buf)
    {
        syslog(LOG_ERR, "vnc_new: %s\n", strerror(errno));
        curl_easy_cleanup(curl);
        close(sock);
        return -1;
    }

    vnc->curl[i] = curl;
    vnc->losock[i] = sock;
    vnc->cusock[i] = fd;
    vnc->lobuf[i] = buf;
    vnc->cubuf[i] = buf + BUF_NSIZE;
    vnc->fdmax = _max(vnc->fdmax, _max(sock, fd));
    FD_SET(fd, &vnc->rdfds);
    FD_SET(sock, &vnc->rdfds);
    syslog(LOG_NOTICE, "vnc_new %d: %s:%d <=> %s%s\n", i, cp->ip, cp->port, cp->host, cp->end);

    return i;
}

static void vnc_connection_free(struct vnc_t *vnc, int i)
{
    syslog(LOG_NOTICE, "vnc_free %d\n", i);
    if (vnc->losock[i])
    {
        FD_CLR(vnc->losock[i], &vnc->rdfds);
        FD_CLR(vnc->losock[i], &vnc->wrfds);
        close(vnc->losock[i]);
    }

    if (vnc->cusock[i])
    {
        FD_CLR(vnc->cusock[i], &vnc->rdfds);
        FD_CLR(vnc->cusock[i], &vnc->wrfds);
    }

    free(vnc->lobuf[i]);
    curl_easy_cleanup(vnc->curl[i]);
    vnc->losock[i] = vnc->cusock[i] = 0;
    vnc->lobuf[i] = vnc->cubuf[i] = NULL;
    vnc->lonum[i] = vnc->cunum[i] = vnc->wsnum[i] = 0;
    vnc->fdmax = find_fdmax(&vnc->rdfds, &vnc->wrfds, vnc->fdmax);
}

static int vnc_handle(struct vnc_t *vnc)
{
    struct cp_t cp;
    struct sockaddr_un client;
    struct sockaddr *clip = (struct sockaddr*) &client;
    char buf[2048];
    socklen_t len = sizeof(struct sockaddr_un);

    const int rc = recvfrom(vnc->lisock, buf, sizeof(buf), 0, clip, &len);
    if (rc == -1)
    {
        syslog(LOG_ERR, "vnc_handle: %s\n", strerror(errno));
        return -1;
    }

    buf[rc] = 0;
    cp.ip = buf;
    char *p = strchr(buf, ' ');
    *p++ = 0;
    cp.port = strtol(p, NULL, 10);
    p = strchr(p, ' ');
    *p++ = 0;
    cp.host = p;
    p = strchr(p, ' ');
    *p++ = 0;
    cp.end = p;
    p = strchr(p, ' ');
    *p++ = 0;
    cp.rest = p;
    char pch[2048];
    size_t n = 0;

    if (vnc_connection_new(vnc, &cp) == -1)
    {
        n = snprintf(pch, sizeof(pch), "%d %s", errno, strerror(errno));
    }
    else
    {
        n = snprintf(pch, sizeof(pch), "%d", 0);
    }

    if (sendto(vnc->lisock, pch, n, MSG_NOSIGNAL, clip, len) == -1)
    {
        syslog(LOG_ERR, "vnc_handle sendto: %s\n", strerror(errno));
        return -1;
    }

    return 0;
}

static int ts_recv(int fd, char *buf, size_t count)
{
    if (count < 126 + 8)
    {
        return 0;
    }

    char pch[BUF_NSIZE], *ptr = buf;
    errno = 0;
    const int c = recv(fd, pch, count - 8, MSG_NOSIGNAL);
    if (c > 0)
    {
        *ptr++ = (unsigned char) 0x82;
        if (c < 125)
        {
            *ptr++ = 0x80 | c;
        } else
        {
            *ptr++ = (unsigned char) 0xfe;
            *ptr++ = (c >> 8);
            *ptr++ = c & 0xff;
        }
        strncpy(ptr, ws_mask, 4);
        ptr += 4;
        for (int i = 0, j = 0; i < c; ++i)
        {
            ptr[i] = pch[i] ^ ws_mask[j++];
            j = j >= 4 ? 0 : j;
        }

        return ptr - buf + c;
    } else
    {
        syslog(LOG_ERR, "ts_recv: %s\n", strerror(errno));
        return -1;
    }
}

static int ts_send(int fd, char *buf, size_t count)
{
    errno = 0;
    int c = send(fd, buf, count, MSG_NOSIGNAL);
    if (c >= 0)
    {
        return c;
    } else if (!TRYAGAIN(errno))
    {
        syslog(LOG_ERR, "ts_send: %s\n", strerror(errno));
        return -1;
    }
    return 0;
}


static int ws_recv(CURL *curl, char *buf, size_t count, uint64_t *wsnum)
{
        if (count < 125)
                return 0;

        size_t n = 0;
        int type = 0;
        CURLcode rc;

        if (*wsnum == 0) { /* new websocket frame */
                char pch[10];
                rc = curl_easy_recv(curl, pch, 2, &n);
                if (n != 2) {
                        if (rc == CURLE_OK)
                                return -1;
                        else if (rc == CURLE_AGAIN)
                                return 0;
                        const char *msg = curl_easy_strerror(rc);
                        syslog(LOG_ERR, "ws_rh[%zu]: %s\n", n, msg);
                        return -1;
                }
                type = pch[0] & 0x0f;
                if (pch[1] < 126) {
                        *wsnum = pch[1];
                } else if (pch[1] == 126) {
                        rc = curl_easy_recv(curl, pch + 2, 2, &n);
                        if (n != 2) {
                                const char *msg = curl_easy_strerror(rc);
                                syslog(LOG_ERR, "ws_r126: %s\n", msg);
                                return -1;
                        }
                        *wsnum = pch[2];
                        *wsnum = (*wsnum << 8) | (0xff & pch[3]);
                } else if (pch[1] == 127) {
                        errno = 0;
                        rc = curl_easy_recv(curl, pch + 2, 8, &n);
                        if (n != 8) {
                                const char *msg = curl_easy_strerror(rc);
                                syslog(LOG_ERR, "ws_r127: %s\n", msg);
                                return -1;
                        }
                        for (int i = 2; i < 10; ++i)
                                *wsnum = (*wsnum << 8) | (0xff & pch[i]);
                }
        }

        if (type > 3) return -type;
        if (*wsnum == 0) return 0;

        n = 0;
        rc = curl_easy_recv(curl, buf, _min(count, *wsnum), &n);
        if (rc == CURLE_OK || rc == CURLE_AGAIN) {
                *wsnum -= n;
                return n;
        } else {
                syslog(LOG_ERR, "ws_recv: %s\n", curl_easy_strerror(rc));
                return -1;
        }
}


static int ws_send(CURL *curl, char *buf, size_t count)
{
    size_t n = 0;
    CURLcode rc = curl_easy_send(curl, buf, count, &n);

    if (rc == CURLE_OK || rc == CURLE_AGAIN)
    {
        return n;
    } else
    {
        syslog(LOG_ERR, "ws_send: %s\n", curl_easy_strerror(rc));
        return -1;
    }
}

static void poll(struct vnc_t *vnc)
{
    fd_set rdfds = vnc->rdfds, wrfds = vnc->wrfds;
    int rc = select(vnc->fdmax + 1, &rdfds, &wrfds, NULL, NULL);

    if (rc < 1)
    {
        syslog(LOG_ERR, "poll: %s\n", strerror(errno));
        return;
    }

    if (FD_ISSET(vnc->lisock, &rdfds))
    {
        vnc_handle(vnc);
    }

    for (int i = 0; i < VNC_NSIZE; ++i)
    {
        if (!vnc->lobuf[i])
        {
            continue;
        }

        const int sock = vnc->losock[i], fd = vnc->cusock[i];
        int a = 0, b = 0, c = 0, d = 0;
        char *lobuf = vnc->lobuf[i], *cubuf = vnc->cubuf[i];
        if (FD_ISSET(sock, &rdfds))
        {
            const short num = vnc->lonum[i];
            a = ts_recv(sock, lobuf + num, BUF_NSIZE - num);

            if (a > 0)
            {
                vnc->lonum[i] += a;
            }

            if (vnc->lonum[i])
            {
                FD_SET(fd, &wrfds);
            }
        }

        if (FD_ISSET(fd, &wrfds))
        {
            const short num = vnc->lonum[i];
            c = ws_send(vnc->curl[i], lobuf, num);
            if (c > 0)
            {
                memmove(lobuf, lobuf + c, num - c);
                vnc->lonum[i] -= c;
            }
        }
        if (FD_ISSET(fd, &rdfds))
        {
            const short num = vnc->cunum[i];
            short *lon = &vnc->lonum[i];
            b = ws_recv(vnc->curl[i], cubuf + num, BUF_NSIZE - num, &vnc->wsnum[i]);

            if (b > 0)
            {
                vnc->cunum[i] += b;
            } else if (b == -9 && *lon + ws_ponglen <= BUF_NSIZE)
            {
                memcpy(lobuf + *lon, ws_pong, ws_ponglen);
                *lon += ws_ponglen;
            } else if (b == -8)
            {
                memcpy(lobuf + *lon, ws_close, ws_closelen);
                *lon += ws_closelen;
            }

            if (vnc->cunum[i])
            {
                FD_SET(sock, &wrfds);
            }
        }

        if (FD_ISSET(sock, &wrfds))
        {
            const short num = vnc->cunum[i];
            d = ts_send(sock, cubuf, num);

            if (d > 0)
            {
                memmove(cubuf, cubuf + d, num - d);
                vnc->cunum[i] -= d;
            }
        }

        if (a != -1 && b != -1 && c != -1 && d != -1)
        {
            if (vnc->lonum[i])
            {
                FD_SET(fd, &vnc->wrfds);
            }
            else
            {
                FD_CLR(fd, &vnc->wrfds);
            }

            if (vnc->cunum[i])
            {
                FD_SET(sock, &vnc->wrfds);
            }
            else
            {
                FD_CLR(sock, &vnc->wrfds);
            }
        } else
        {
            vnc_connection_free(vnc, i);
        }
    }
}

int main()
{
    struct vnc_t *vnc = vnc_init();
    if (!vnc)
    {
        return 0;
    }

    while (1)
    {
        poll(vnc);
    }

    return 0;
}
