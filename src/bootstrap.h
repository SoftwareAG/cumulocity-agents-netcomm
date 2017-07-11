#ifndef BOOTSTRAP_H
#define BOOTSTRAP_H

#include <srbootstrap.h>
#include <srwatchdogtimer.h>

#include "common/rdbmanager.h"

class Bootstrap: public SrBootstrap
{
public:

    Bootstrap(const std::string &server, const std::string &deviceID,
            RdbManager& _rdb, SrWatchdogTimer &wdt) :
            SrBootstrap(server, deviceID), rdb(_rdb), wdt(wdt)
    {
    }

    virtual ~Bootstrap()
    {
    }

protected:

    virtual int loadCredential(const std::string &path);
    virtual int requestCredential();
    virtual int saveCredential(const std::string &path);

private:

    RdbManager &rdb;
    SrWatchdogTimer &wdt;
};

#endif /* BOOTSTRAP_H */
