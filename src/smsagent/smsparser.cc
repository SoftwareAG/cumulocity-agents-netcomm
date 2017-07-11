#include <fstream>
#include <syslog.h>
#include "smsparser.h"

using namespace std;

#define IN_BUF_SIZE (32 * (sizeof(struct inotify_event) + 32))

int SMSParser::parseSMS(const string &path)
{
    ifstream in(path);
    string s;
    bool flag = false;

    for (string s2; getline(in, s2);)
    {
        if (s2.size() > 6
                && (s2.compare(0, 4, "GSM7") == 0
                        || s2.compare(0, 4, "UCS2") == 0))
        {
            s2.erase(0, 5);
            flag = true;
        }

        if (flag)
        {
            s += s2;
        }
    }

    syslog(LOG_NOTICE, "new sms %s: %s", path.c_str(), s.c_str());
    size_t pos = s.find(',');
    if (s.compare(0, pos, sn))
    {
        return EAUTH_SN;
    }

    pos = pos != string::npos ? pos + 1 : s.size();
    size_t pos2 = s.find(' ', pos);
    const size_t len = pos2 != string::npos ? pos2 - pos : string::npos;
    if (s.compare(pos, len, imsi))
    {
        return EAUTH_IMSI;
    }

    pos2 = pos2 != string::npos ? pos2 + 1 : s.size();
    if (s.compare(pos2, string::npos, "STATUS_REQUEST") == 0)
    {
        reporting = true;
    }
    else if (s.compare(pos2, string::npos, "TO_IP") == 0)
    {
        toip = true;
    }
    else if (s.compare(pos2, string::npos, "REBOOT") == 0)
    {
        rebooting = true;
    }
    else if (s.compare(pos2, string::npos, "RESTART") == 0)
    {
        rebooting = true;
    }
    else
    {
        return ECMD;
    }

    return 0;
}

int SMSParser::update()
{
    struct timeval tv = { 1, 0 };
    char b[IN_BUF_SIZE];
    fd_set ins;
    FD_ZERO(&ins);
    FD_SET(infd, &ins);
    int ret = -1;

    if (select(infd + 1, &ins, NULL, NULL, &tv) && FD_ISSET(infd, &ins))
    {
        int len = read(infd, b, IN_BUF_SIZE);
        for (int i = 0; i < len;)
        {
            struct inotify_event *e = (struct inotify_event*) &b[i];
            i += sizeof(struct inotify_event) + e->len;
            if (e->len == 0 || (e->mask & IN_ISDIR))
                continue;

            const string name(e->name);
            size_t pos = name.size() > 6 ? name.size() - 6 : 0;
            if (name.compare(pos, 6, "unread") == 0)
            {
                sleep(5);
                int c = parseSMS(inbox + name);
                ret = c ? c : ret;
            }
        }
    }

    return ret;
}
