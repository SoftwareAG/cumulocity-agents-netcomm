#ifndef UDPALARM_H
#define UDPALARM_H

#include <sys/socket.h>
#include <fcntl.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <sragent.h>
#include "common/rdbmanager.h"
#define keyUDPPort "service.cumulocity.udp_alarms.port"



class UdpAlarm: public AbstractTimerFunctor
{
public:

    UdpAlarm(SrAgent &agent, const RdbManager &rdb) :
            timer(30 * 1000, this), rdb(rdb), sock(0)
    {
        agent.addTimer(timer);
        timer.start();
        sock = socket(AF_INET, SOCK_DGRAM, 0);
        const int x = fcntl(sock, F_GETFL, 0);
        fcntl(sock, F_SETFL, x | O_NONBLOCK);

        addr.sin_family = AF_INET;
        inet_aton("127.0.0.1", &addr.sin_addr);
        const std::string k = rdb.get(keyUDPPort);
        const uint16_t port = strtoul(k.c_str(), NULL, 10);
        addr.sin_port = htons(port);
        const socklen_t len = sizeof(addr);
        bind(sock, (const struct sockaddr*) &addr, len);
    }

    virtual ~UdpAlarm()
    {
    }

    void operator()(SrTimer &timer, SrAgent &agent);

private:

    struct sockaddr_in addr;
    SrTimer timer;
    const RdbManager &rdb;
    int sock;
};

#endif /* UDPALARM_H */
