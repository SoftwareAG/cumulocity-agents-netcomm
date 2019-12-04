#include "rdbmonitor.h"

const std::string keyQuota = "service.cumulocity.log.quota";
const std::string keyLevel = "service.cumulocity.log.level";
const std::string keyCap = "service.cumulocity.buffer.capacity";

#define DEFAULT_QUOTA_KB 1024
#define DEFAULT_CAPACITY_SLOTS_NUM 10000
#define MAX_LOG_LEVEL 8

RdbMonitor::RdbMonitor(const RdbManager &rdb, SrAgent &agent, SrWatchdogTimer &w) :
        timer(5000, this), rdb(rdb), wdt(w), rpt(NULL)
{
    static const int arr[] =
    { 804, 805, 807, 813, 815, 817, 818, 819, 820, 833, 834, 838, 841, 842, 843,
            845, 846, 849, 850, 853, 854, 855, 858, 859, 863, 865, 866, 867,
            868, 869, 870, 871, 872, 873, 874, 875, 877, 878, 881, 882 };
    const int N = sizeof(arr) / sizeof(arr[0]);

    for (int i = 0; i < N; ++i)
    {
        agent.addMsgHandler(arr[i], this);
    }

    agent.addTimer(timer);
    timer.start();
    monitor(rdb, rpt);
}

void RdbMonitor::operator()(SrRecord &r, SrAgent &agent)
{
    SrNews news("304,");
    std::string s;

    unsigned int i = strtoul(r.value(0).c_str(), NULL, 10);
    switch (i)
    {
    case 804:
    case 853:
        s = "restart";
        break;
    case 807:
    case 855:
        s = "shell";
        break;
    case 805:
    case 841:
    case 842:
    case 843:
    case 854:
    case 871:
    case 872:
    case 873:
        s = "config";
        break;
    case 813:
    case 858:
        s = "logview";
        break;
    case 815:
    case 845:
    case 859:
    case 874:
        s = "software";
        break;
    case 817:
    case 833:
    case 834:
    case 849:
    case 863:
    case 868:
    case 869:
    case 878:
        s = "modbus";
        break;
    case 818:
    case 819:
    case 820:
    case 865:
    case 866:
    case 867:
        s = "net";
        break;
    case 838:
    case 870:
        s = "relay";
        break;
    case 846:
    case 850:
    case 875:
    case 877:
        s = "support";
        break;
    case 881:
    case 882:
        s = "tcsbus";
        break;
    }

    if (!s.empty())
    {
        news.data += r.value(2);
        news.data += i > 880 ? ",\"module " : ",\"plugin ";
        news.data += s + " disabled\"";
        agent.send(news);
    }
}

void monitor(const RdbManager &rdb, SrReporter *rpt)
{
    uint16_t quota = strtoul(rdb.get(keyQuota).c_str(), NULL, 10);
    quota = quota ? quota : DEFAULT_QUOTA_KB;
    srLogSetQuota(quota);

    uint16_t logLevel = strtoul(rdb.get(keyLevel).c_str(), NULL, 10);
    logLevel = logLevel > MAX_LOG_LEVEL ? MAX_LOG_LEVEL : logLevel;
    srLogSetLevel(SrLogLevel(4 - logLevel / 2));

    if (rpt)
    {
        const uint16_t capacity = strtoul(rdb.get(keyCap).c_str(), NULL, 10);
        rpt->setCapacity(capacity ? capacity : DEFAULT_CAPACITY_SLOTS_NUM);
    }
}
