#include <syslog.h>
#include <srwatchdogtimer.h>
#include <string>
#include "common/rdbmanager.h"
#include "common/gpio.h"
#include "smsparser.h"

using namespace std;

static const char kSignal[] = "wwan.0.radio.information.signal_strength";
static const char kRSCP[] = "wwan.0.system_network_status.RSCPs0";
static const char kConfirm[] = "service.cumulocity.modeswitching.confirm";
static const char kReceiver[] = "service.cumulocity.sms.receiver";
static const char kEnable[] = "service.cumulocity.sms.enable";
static const char kReportVal[] = "service.cumulocity.sms.report.interval";
static const char kUsername[] = "service.cumulocity.connection.username";

static int signal(const RdbManager &rdb)
{
    int sig = strtol(rdb.get(kSignal).c_str(), NULL, 0);
    sig = sig ? sig : -strtol(rdb.get(kRSCP).c_str(), NULL, 0);

    // Normalize raw signal quality from dBm to range [0,32]
    if (sig > -113 && sig < -51)
        return (sig + 113) / 2;
    else if (sig >= -51 && sig < 0)
        return 32;
    else
        return sig <= -113 ? 0 : 99; // 99: not detectable
}

static int sendSMS(const string &receiver, const string &text)
{
    const string cmd = "/usr/bin/sendsms " + receiver + " '" + text + "'";

    return system(cmd.c_str());
}

static string curTime()
{
    char buf[30];
    const time_t t = time(NULL);
    strftime(buf, sizeof(buf), "%FT%T+0000", gmtime(&t));

    return buf;
}

static int report(const string &receiver, const string &sn, const string &imsi,
        const string &tenant, int sig, int alarm1, int alarm2,
        const string &mode = "SMS")
{
    string text = sn + "," + imsi + "," + tenant + ",P," + curTime() + ",";
    text += mode + "," + to_string(sig) + ",";
    text += to_string(alarm1) + "," + to_string(alarm2);
    syslog(LOG_NOTICE, "%s reporter s: %s", receiver.c_str(), text.c_str());

    return sendSMS(receiver, text);
}

static int raiseAlarm(const string &receiver, const string &sn,
        const string &imsi, const string &tenant, const string &name, int alarm,
        const string &des)
{
    string text = sn + "," + imsi + "," + tenant + ",A," + name + ",";
    text += curTime() + "," + to_string(alarm) + "," + des;
    syslog(LOG_NOTICE, (receiver + " alarm: " + text).c_str());

    return sendSMS(receiver, text);
}

static string getTenant(const string &username)
{
    return username.substr(0, username.find('/'));
}

static int confirm(RdbManager &rdb, const string &k, const string &v)
{
    if (rdb.set(k, v))
    {
        return rdb.create(k, v, CREATE);
    }

    return 0;
}

int main()
{
    setlogmask(LOG_UPTO(LOG_NOTICE));
    RdbManager rdb;
    const string sn = rdb.get("uboot.sn");
    const uint8_t num = 2;
    GPIO G[num] =
    { GPIO("xaux1", rdb), GPIO("xaux2", rdb) };

    SrWatchdogTimer wdt;
    wdt.start();
    while (true)
    {
        sleep(2);
        wdt.kick();
        if (!strtoul(rdb.get(kEnable).c_str(), NULL, 0))
        {
            continue;
        }

        const string tenant = getTenant(rdb.get(kUsername));
        string receiver = rdb.get(kReceiver);
        if (tenant.empty() || receiver.empty() || confirm(rdb, kConfirm, "1"))
        {
            continue;
        }

        const string imsi = rdb.get("wwan.0.imsi.msin");
        if (imsi.empty())
        {
            continue;
        }

        const string inbox = rdb.get("smstools.inbox_path") + "/";
        SMSParser parser(sn, imsi, inbox);
        long tReport = -1000000; // time for last status report.

        syslog(LOG_NOTICE, "SMS mode enabled");
        while (strtoul(rdb.get(kEnable).c_str(), NULL, 0))
        {
            sleep(1);
            wdt.kick();
            receiver = rdb.get(kReceiver);

            if (receiver.empty())
            {
                continue;
            }

            for (uint8_t i = 0; i < num; ++i)
            {
                G[i].poll();
                G[i].debounce();
                if (!G[i].alarm())
                {
                    continue;
                }

                raiseAlarm(receiver, sn, imsi, tenant, G[i].name(), G[i].vdigit(), G[i].alarmText());
                G[i].clear();
                wdt.kick();
            }

            parser.update();
            if (parser.isReboot())
            {
                rdb.set("service.system.reset", "1");
            }

            if (parser.isToIP())
            {
                rdb.set(kEnable, "0");
            }

            const string k = rdb.get(kReportVal);
            const int val = strtoul(k.c_str(), NULL, 0);
            timespec t1;
            clock_gettime(CLOCK_MONOTONIC, &t1);
            if (parser.isReport() || t1.tv_sec - tReport >= val)
            {
                tReport = t1.tv_sec;
                G[0].poll();
                G[1].poll();
                report(receiver, sn, imsi, tenant, signal(rdb), G[0].vdigit(),
                        G[1].vdigit());
            }
            parser.clear();
        }

        G[0].poll();
        G[1].poll();
        report(rdb.get(kReceiver), sn, imsi, tenant, signal(rdb), G[0].vdigit(), G[1].vdigit(), "IP");
        confirm(rdb, kConfirm, "0");
    }

    return 0;
}
