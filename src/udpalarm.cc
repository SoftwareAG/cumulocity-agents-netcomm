#include <ctime>
#include <cstring>
#include <srlogger.h>
#include "udpalarm.h"

using namespace std;

static int parseEvent(const char *s, int len, int &id, char *d, char *t, int &n)
{
    if (len < 42)
    {
        return -1;
    }

    const int c = sscanf(s, "[EVENT#%d] %[0-9-] %[0-9:] %n", &id, d, t, &n);

    return c == 3 ? 0 : -1;
}

static string sever(int i)
{
    if (i >= 1 && i <= 3)
    {
        return ",MAJOR,\"";
    }
    else if (i >= 4 && i <= 10)
    {
        return ",WARNING,\"";
    }
    else
    {
        return ",MINOR,\"";
    }
}

void UdpAlarm::operator()(SrTimer &timer, SrAgent &agent)
{
    (void) timer;
    (void) agent;
    char buf[512];
    int c = recv(sock, buf, sizeof(buf), 0);

    if (c >= 0)
    {
        buf[c] = 0;
        while (c && buf[c - 1] == '\n')
        {
            buf[--c] = 0;
        }

        srDebug(string("udpalarm: ") + buf);
        int id, n;
        char d[15], t[15];
        if (parseEvent(buf, c, id, d, t, n) != 0)
        {
            srWarning("udpalarm: parse error");
            return;
        }

        const string alarmid = "udpalarm." + to_string(id);
        char timezone[10];
        time_t t0 = time(NULL);
        strftime(timezone, sizeof(timezone), "%z", localtime(&t0));

        const string ts = string(d) + "T" + t + timezone;
        const SrNews news("334," + ts + "," + agent.ID() + "," + alarmid + sever(id) + (buf + n) + "\"");
        agent.send(news);

    } else if (errno != EWOULDBLOCK && errno != EAGAIN)
    {
        srError(std::string("udpalarm: ") + strerror(errno));
    }
}
