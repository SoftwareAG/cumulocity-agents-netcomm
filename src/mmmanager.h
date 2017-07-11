#ifndef MMMANAGER_H
#define MMMANAGER_H

#include <memory>
#include <deque>
#include "mbbase.h"

class MMManager
{
public:
    MMManager()
    {
    }

    virtual ~MMManager()
    {
    }

    ModbusModel *newModel()
    {
        mm.emplace_back(new ModbusModel());
        return mm.back().get();
    }

private:
    std::deque<std::unique_ptr<ModbusModel>> mm;
};

#endif /* MMMANAGER_H */
