#ifndef RDBMONITOR_H
#define RDBMONITOR_H

#include <srwatchdogtimer.h>
#include <sragent.h>
#include <srreporter.h>
#include "gpiomanager.h"

void monitor(const RdbManager &rdb, SrReporter *rpt);

class RdbMonitor: public AbstractTimerFunctor, public AbstractMsgHandler
{
public:

    RdbMonitor(const RdbManager &rdb, SrAgent &agent, SrWatchdogTimer &w);
    virtual ~RdbMonitor()
    {
    }

    void operator()(SrTimer &timer, SrAgent &agent)
    {
        (void) timer;
        (void) agent;
        wdt.kick();
        monitor(rdb, rpt);
    }

    void operator()(SrRecord &r, SrAgent &agent);
    void setReporter(SrReporter *reporter)
    {
        rpt = reporter;
    }


private:

    SrTimer timer;
    const RdbManager &rdb;
    SrWatchdogTimer &wdt;
    SrReporter *rpt;
};

#endif /* RDBMONITOR_H */
