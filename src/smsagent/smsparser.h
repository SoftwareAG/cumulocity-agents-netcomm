#ifndef SMSPARSER_H
#define SMSPARSER_H

#include <string>
#include <unistd.h>
#include <sys/inotify.h>

#define EAUTH_SN 1
#define EAUTH_IMSI 2
#define ECMD 3

#define IN_FLAGS (IN_CREATE | IN_MOVED_TO)

class SMSParser
{
public:

    using string = std::string;
    SMSParser(const string &sn, const string &imsi, const string &inbox) :
            sn(sn), imsi(imsi), inbox(inbox), toip(false), reporting(false), rebooting(
                    false)
    {
        infd = inotify_init();
        wd = inotify_add_watch(infd, inbox.c_str(), IN_FLAGS);
    }

    virtual ~SMSParser()
    {
        inotify_rm_watch(infd, wd);
        close(infd);
    }

    int update();

    bool isReboot() const
    {
        return rebooting;
    }

    bool isReport() const
    {
        return reporting;
    }

    bool isToIP() const
    {
        return toip;
    }

    void clear()
    {
        toip = false;
        reporting = false;
        rebooting = false;
    }

private:

    int parseSMS(const string &path);

private:

    const string sn;
    const string imsi;
    const string inbox;
    bool toip;              // [Indicator]: Switch to IP mode
    bool reporting;         // [Indicator]: Status report request
    bool rebooting;         // [Indicator]: reboot command
    int infd;
    int wd;
};

#endif /* SMSPARSER_H */
