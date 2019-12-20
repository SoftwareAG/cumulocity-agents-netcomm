#include <ctime>
#include <cstring>
#include <srlogger.h>
#include <algorithm>
#include "udpalarm.h"

using namespace std;

static int getMonthIndex(string name)
{
    std::transform(name.begin(), name.end(), name.begin(), ::tolower);
    map<string, int> months
    {
        { "jan", 1 },
        { "feb", 2 },
        { "mar", 3 },
        { "apr", 4 },
        { "may", 5 },
        { "jun", 6 },
        { "jul", 7 },
        { "aug", 8 },
        { "sep", 9 },
        { "oct", 10 },
        { "nov", 11 },
        { "dec", 12 }
    };
    const auto iter = months.find(name);
    if( iter != months.cend() )
        return iter->second;
    return -1;
}

static int parseEvent(const char *eventstr, int len, int &eventid, char *dest, char *createdtime, int &num)
{
    const int minlength = 47;
    if (len < minlength)
    {
        return -1;
    }

    char year[5], month[4], day[3];
    const int c = sscanf(eventstr, "<%*d> %s %s %[0-9:] %*s [EVENT#%d] %n", month, day, createdtime, &eventid, &num);

    time_t t0 = time(NULL);
    strftime(year, sizeof(year), "%Y", localtime(&t0));

    if (c == 4) {
        snprintf(dest, 11, "%s-%02d-%s", year, getMonthIndex(std::string(month)), day); // format yyyy-mm-dd
    } else {
        return -1;
    }
    return 0;
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
