#include "rdbmonitor.h"

const std::string keyQuota = "service.cumulocity.log.quota";
const std::string keyLevel = "service.cumulocity.log.level";
const std::string keyCap = "service.cumulocity.buffer.capacity";

RdbMonitor::RdbMonitor(const RdbManager &rdb, SrAgent &agent,
        SrWatchdogTimer &w) :
        timer(5000, this), rdb(rdb), wdt(w), rpt(NULL)
{
    const int arr[] =
    { 804, 805, 807, 813, 815, 817, 818, 819, 820, 833, 834, 838, 841, 842, 843,
            845, 846, 849, 850, 853, 854, 855, 858, 859, 863, 865, 866, 867,
            868, 869, 870, 871, 872, 873, 874, 875, 877, 878};
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
        switch (i) {
        case 804:
        case 853: s = "restart"; break;
        case 807:
        case 855: s = "shell"; break;
        case 805:
        case 841:
        case 842:
        case 843:
        case 854:
        case 871:
        case 872:
        case 873: s = "config"; break;
        case 813:
        case 858: s = "logview"; break;
        case 815:
        case 845:
        case 859:
        case 874: s = "software"; break;
        case 817:
        case 833:
        case 834:
        case 849:
        case 863:
        case 868:
        case 869:
        case 878: s = "modbus"; break;
        case 818:
        case 819:
        case 820:
        case 865:
        case 866:
        case 867: s = "net"; break;
        case 838:
        case 870: s = "relay"; break;
        case 846:
        case 850:
        case 875:
        case 877: s = "support"; break;
        }
        if (!s.empty()) {
                news.data += r.value(2) + ",\"plugin " + s + " disabled\"";
                agent.send(news);
        }
}

void monitor(const RdbManager &rdb, SrReporter *rpt)
{
    uint16_t i = strtoul(rdb.get(keyQuota).c_str(), NULL, 10);
    i = i ? i : 1024;
    srLogSetQuota(i);
    i = strtoul(rdb.get(keyLevel).c_str(), NULL, 10);
    i = i > 8 ? 8 : i;
    srLogSetLevel(SrLogLevel(4 - i / 2));

    if (rpt)
    {
        i = strtoul(rdb.get(keyCap).c_str(), NULL, 10);
        rpt->setCapacity(i ? i : 10000);
    }
}
