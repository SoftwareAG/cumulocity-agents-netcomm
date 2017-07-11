#ifndef MODESWITCHER_H
#define MODESWITCHER_H

#include <sragent.h>
#include <srdevicepush.h>
#include <srreporter.h>
#include "common/rdbmanager.h"

class ModeSwitcher: public AbstractMsgHandler, public AbstractTimerFunctor
{
public:

    ModeSwitcher(RdbManager &rdb, SrReporter *rep, SrDevicePush *push,
            SrAgent &agent) :
            timer(5000, this), rdb(rdb), rep(rep), push(push), oldEnable(0)
    {
        agent.addMsgHandler(810, this);
        agent.addMsgHandler(857, this);
        agent.addTimer(timer);
        timer.start();
    }

    virtual ~ModeSwitcher()
    {
    }

    void operator()(SrTimer &t, SrAgent &agent);
    void operator()(SrRecord &r, SrAgent &agent);

private:

    SrTimer timer;
    std::string opId;
    RdbManager &rdb;
    SrReporter *rep;
    SrDevicePush *push;
    uint8_t oldEnable;
};

#endif /* MODESWITCHER_H */
