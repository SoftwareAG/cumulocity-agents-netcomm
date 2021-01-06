#ifndef LUAMANAGER_H
#define LUAMANAGER_H

#include <srnethttp.h>
#include <srlogger.h>
#include <srluapluginmanager.h>
#include "modbus/mbmanager.h"


class LuaManager: public SrLuaPluginManager
{
public:
        LuaManager(SrAgent &agent):
                SrLuaPluginManager(agent), mb(),
                http(agent.server() + "/s", agent.XID(), agent.auth()) {}

        virtual ~LuaManager() {}

protected:
    void init(lua_State *L)
    {
        SrLuaPluginManager::init(L);
        getGlobalNamespace(L)
                .beginClass<ModbusBase>("_ModbusBase")
                .addFunction("poll", &ModbusBase::poll)
                .addFunction("getCoilValue", &ModbusBase::getCoilValue)
                .addFunction("getRegValue", &ModbusBase::getRegValue)
                .addFunction("size", &ModbusBase::size)
                .addFunction("updateCO", &ModbusBase::updateCO)
                .addFunction("updateHRBits", &ModbusBase::updateHRBits)
                .addFunction("errMsg", &ModbusBase::errMsg)
                .addFunction("getTimeout", &ModbusBase::getTimeout)
                .addFunction("setTimeout", &ModbusBase::setTimeout)
                .endClass()
                .deriveClass<ModbusTCP, ModbusBase>("ModbusTCP")
                .endClass()
                .deriveClass<ModbusRTU, ModbusBase>("ModbusRTU")
                .addFunction("setConf", &ModbusRTU::setConf)
                .endClass()
                .beginClass<MBManager>("MBManager")
                .addConstructor<void (*) ()> ()
                .addFunction("newTCP", &MBManager::newTCP)
                .addFunction("newRTU", &MBManager::newRTU)
                .addFunction("newModel", &MBManager::newModel)
                .endClass()
                .beginClass<ModbusModel>("ModbusModel")
                .addFunction("addAddress", &ModbusModel::addAddress)
                .endClass()
                .deriveClass<SrNetHttp, SrNetInterface>("SrNetHttp")
                .addFunction("post", &SrNetHttp::post)
                .endClass();
        push(L, &mb);
        lua_setglobal(L, "MB");
        push(L, &http);
        lua_setglobal(L, "http");
    }

private:

    MBManager mb;
    SrNetHttp http;
};

#endif /* LUAMANAGER_H */
