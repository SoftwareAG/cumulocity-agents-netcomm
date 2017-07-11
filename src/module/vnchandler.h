#ifndef VNCHANDLER_H
#define VNCHANDLER_H

#include <sys/types.h>
#include <sys/socket.h>
#include <sys/un.h>
#include <sragent.h>
#include "../vnc/vnc.h"

class VncHandler: public SrMsgHandler, public SrTimerHandler
{
public:
    VncHandler(SrAgent &agent) : timer(3000, this), sock(-1)
    {
        agent.addMsgHandler(886, this);
        agent.addTimer(timer);

        memset(&addr, 0, sizeof(struct sockaddr_un));
        memset(&server, 0, sizeof(struct sockaddr_un));
        remove(CPATH);
        addr.sun_family = server.sun_family = AF_UNIX;
        strcpy(addr.sun_path, CPATH);
        strcpy(server.sun_path, SPATH);
        opid = 0;
        retries = 0;
    }

    void operator()(SrRecord &r, SrAgent &agent);
    void operator()(SrTimer &timer, SrAgent &agent);

private:

    SrTimer timer;
    struct sockaddr_un addr;
    struct sockaddr_un server;
    int sock;
    int opid;
    int retries;
};

#endif /* VNCHANDLER_H */
