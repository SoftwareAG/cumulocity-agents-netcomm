#include "modeswitcher.h"
using namespace std;

static const char kEnable[] = "service.cumulocity.sms.enable";
static const char kConfirm[] = "service.cumulocity.modeswitching.confirm";
static const char kSMSReason[] = "service.cumulocity.sms.failurereason";

void ModeSwitcher::operator()(SrTimer &t, SrAgent &agent)
{
    (void) t;
    const uint8_t enable = strtoul(rdb.get(kEnable).c_str(), NULL, 10);
    const int confirm = strtoul(rdb.get(kConfirm).c_str(), NULL, 10);

    if (oldEnable != enable)
    {
        if (enable == 0)
        {
            rep->resume();
            if (push)
                push->resume();
            oldEnable = enable;
        } else if (confirm == 1)
        {
            rep->sleep();
            if (push)
                push->sleep();
            oldEnable = enable;
            opId.clear();
        }
    }

    if (!opId.empty())
    {
        string s = rdb.get(kSMSReason);
        s = s.empty() ? "Timed out" : s;
        agent.send(SrNews("304," + opId + "," + s));
        opId.clear();
        rdb.set(kEnable, "0");
    }
}

void ModeSwitcher::operator()(SrRecord &r, SrAgent &agent)
{
    SrNews news;

    if (r.size() >= 4 && r[3].second == "SMS")
    {
        if (rdb.set(kEnable, "1"))
        {
            rdb.create(kEnable, "1", PERSIST);
        }

        news.data = "303," + r[2].second + ",EXECUTING";
        opId = r[2].second;
        timer.start();
    } else if (r.size() >= 3)
    {
        news.data = "304," + r[2].second + ",Cannot switch to mode ";
        news.data += r.size() > 3 ? r[3].second : " unknown";
    }

    agent.send(news);
}
