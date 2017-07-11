#ifndef GPIOMANAGER_H
#define GPIOMANAGER_H

#include <sstream>
#include <vector>
#include <sragent.h>
#include <srlogger.h>
#include "common/gpio.h"

class GPIOManager: public AbstractTimerFunctor, public AbstractMsgHandler
{
public:

    GPIOManager(const std::string &pins, const RdbManager &rdb, SrAgent &a) :
            timer(1000, this), t0(0), rdb(rdb)
    {
        std::istringstream iss(pins);
        for (std::string sub; getline(iss, sub, ',');)
        {
            v.push_back(new GPIO(sub, rdb));
            const GPIO *p = v.back();
            srDebug("GPIO: " + p->pin() + ", " + p->name());
        }

        a.addTimer(timer);
        a.addMsgHandler(808, this);
        a.addMsgHandler(809, this);
        a.addMsgHandler(856, this);
        timer.start();
    }

    virtual ~GPIOManager()
    {
        for (auto &e : v)
        {
            delete e;
        }
    }

    virtual void operator()(SrTimer &timer, SrAgent &agent);
    virtual void operator()(SrRecord &r, SrAgent &agent);

private:

    std::vector<GPIO*> v;
    SrTimer timer;
    time_t t0;
    const RdbManager &rdb;
};

#endif /* GPIOMANAGER_H */
