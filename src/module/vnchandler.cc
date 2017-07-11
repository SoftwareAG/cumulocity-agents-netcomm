#include <unistd.h>
#include <sys/stat.h>
#include <srlogger.h>
#include "vnchandler.h"

using namespace std;
static const socklen_t len = sizeof(struct sockaddr_un);

static int us_socket(struct sockaddr_un *addr)
{
    const int sock = socket(AF_UNIX, SOCK_DGRAM, 0);

    if (sock == -1)
    {
        srWarning(string("VNC socket: ") + strerror(errno));

        return -1;
    }

    if (bind(sock, (struct sockaddr*) addr, len) == -1)
    {
        close(sock);

        srWarning(string("VNC bind: ") + strerror(errno));

        return -1;
    }

    chmod(CPATH, 0666);

    return sock;
}

void VncHandler::operator()(SrTimer &timer, SrAgent &agent)
{
    char buf[1024];
    int rc = recv(sock, buf, sizeof(buf), MSG_NOSIGNAL | MSG_DONTWAIT);

    if (rc == -1 && (errno == EWOULDBLOCK || errno == EAGAIN))
    {
        srDebug(string("recv: ") + strerror(errno));

        if (--retries <= 0)
        {
            srWarning("VNC: proxy no respond");
            agent.send("304," + to_string(opid) + ",proxy no respond");
            timer.stop();
        }

        return;
    } else if (rc == -1)
    {
        srError(string("VNC: ") + strerror(errno));

        agent.send("304," + to_string(opid) + ',' + strerror(errno));
        sock = -1;
        timer.stop();

        return;
    }

    buf[rc] = 0;
    char *p;
    rc = strtol(buf, &p, 10);
    if (rc)
    {
        agent.send("304," + to_string(opid) + ',' + (++p));
    } else
    {
        agent.send("303," + to_string(opid) + ",SUCCESSFUL");
    }

    timer.stop();
}

void VncHandler::operator()(SrRecord &r, SrAgent &agent)
{
    agent.send("303," + r.value(2) + ",EXECUTING");

    if (sock == -1)
    {
        sock = us_socket(&addr);
    }

    if (sock == -1)
    {
        agent.send("304," + r.value(2) + ',' + strerror(errno));
        return;
    }

    string buf = r.value(3) + ' ' + r.value(4) + ' ' + agent.server() + ' ';
    buf += "/service/remoteaccess/device/" + r.value(5) + ' ';
    buf += agent.auth();
    const int rc = sendto(sock, buf.c_str(), buf.size(), MSG_NOSIGNAL, (struct sockaddr*) &server, len);

    if (rc == -1)
    {
        agent.send("304," + r.value(2) + ',' + strerror(errno));
        return;
    }

    opid = strtol(r.value(2).c_str(), NULL, 10);
    timer.start();
    retries = 40;
}
