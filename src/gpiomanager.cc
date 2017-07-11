#include <srtypes.h>
#include "gpiomanager.h"

using namespace std;

const string keyval = "service.cumulocity.gpio.interval";

static void raiseAlarm(const GPIO &g, SrAgent &agent)
{
    SrNews news;
    news.data = "312," + agent.ID() + "," + g.name() + ",";
    news.data += g.alarmSeverity() + ",\"" + g.alarmText() + "\"";
    agent.send(news);
}

static void loop(vector<GPIO*> &v, SrAgent &agent, bool debounce, bool measure)
{
    bool clear = false;

    for (auto &p : v)
    {
        p->poll();
        if (p->notifyMode() == GPIO::Alarm)
        {
            bool alarm = true;
            if (debounce)
            {
                p->debounce();
                alarm = p->alarm();
                if (alarm)
                {
                    p->clear();
                }
            }

            if (alarm)
            {
                if (p->vdigit())
                {
                    raiseAlarm(*p, agent);
                }
                else
                {
                    clear = true;
                }
            }
        } else if (p->notifyMode() == GPIO::Measurement && measure)
        {
            char buf[30];
            const time_t t = time(NULL);
            const char *fmt = "%Y-%m-%dT%H:%M:%S+0000";
            auto s = strftime(buf, sizeof(buf), fmt, gmtime(&t));

            buf[s] = ',';
            buf[s + 1] = 0;
            SrNews news(string("322,") + buf + agent.ID() + ',');
            news.data += p->name() + ',' + to_string(p->vanalog());
            news.prio = SR_PRIO_BUF;
            agent.send(news);
        }
    }

    if (clear)
    {
        SrNews news("311," + agent.ID() + ",ACTIVE" + "\n");
        news.data += "311," + agent.ID() + ",ACKNOWLEDGED";
        agent.send(news);
    }
}

void GPIOManager::operator()(SrTimer &timer, SrAgent &agent)
{
    (void) timer;
    const int val = strtoul(rdb.get(keyval).c_str(), NULL, 10);
    bool measurement = false;

    timespec ts = { 0, 0 };
    clock_gettime(CLOCK_MONOTONIC, &ts);

    if (val && t0 + val <= ts.tv_sec)
    {
        measurement = true;
        t0 = ts.tv_sec;
    }

    loop(v, agent, true, measurement);
}

void GPIOManager::operator()(SrRecord &r, SrAgent &agent)
{
    if (r.value(0) == "809" || r.value(0) == "856")
    {
        loop(v, agent, false, true);
        SrNews news("303," + r.value(2) + ",SUCCESSFUL", SR_PRIO_BUF);
        agent.send(news);
    } else if (r.value(0) == "808")
    {
        if (r.size() < 4)
        {
            return;
        }

        for (size_t i = 0; i < v.size(); ++i)
        {
            if (v[i]->name() == r.value(3) && v[i]->poll() == 0 && v[i]->vdigit() == 0)
            {
                agent.send(SrNews("313," + r.value(2)));
                break;
            }
        }
    }
}
