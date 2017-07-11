#ifndef INTEGRATE_H
#define INTEGRATE_H

#include <sragent.h>
#include <srwatchdogtimer.h>
#include "common/rdbmanager.h"

class Integrate: public SrIntegrate
{
public:
    Integrate(RdbManager &r, SrWatchdogTimer &w) :
            SrIntegrate(), rdb(r), wdt(w)
    {
    }

    virtual ~Integrate()
    {
    }

    virtual int integrate(const SrAgent &agent, const string &srv,
            const string &srt);

private:

    RdbManager &rdb;
    SrWatchdogTimer &wdt;
};

#endif /* INTEGRATE_H */
