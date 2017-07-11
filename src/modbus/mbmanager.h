#ifndef MBMANAGER_H
#define MBMANAGER_H

#include <memory>
#include <algorithm>
#include "mbbase.h"

class MBManager
{
public:

    MBManager() :
            rtu(nullptr)
    {
    }

    virtual ~MBManager()
    {
    }

    ModbusTCP *newTCP(const char *ip, int port)
    {
        auto pred = [&ip](const std::pair<std::string,
                std::unique_ptr<ModbusTCP>> &T)
        {   return T.first == ip;};
        auto it = std::find_if(mb.begin(), mb.end(), pred);

        if (it != mb.end())
        {
            return it->second.get();
        } else
        {
            std::unique_ptr<ModbusTCP> p(new ModbusTCP(ip, port));
            mb.emplace_back(ip, std::move(p));

            return mb.back().second.get();
        }
    }

    ModbusRTU *newRTU(const char *dev, int baud, char par, int data, int stop)
    {
        if (rtu == nullptr)
        {
            rtu.reset(new ModbusRTU(dev, baud, par, data, stop));
        }

        return rtu.get();
    }

    ModbusModel *newModel()
    {
        mm.emplace_back(new ModbusModel());
        return mm.back().get();
    }

private:

    std::deque<std::pair<std::string, std::unique_ptr<ModbusTCP>>>mb;
    std::deque<std::unique_ptr<ModbusModel>> mm;
    std::unique_ptr<ModbusRTU> rtu;
};

#endif /* MBMANAGER_H */
