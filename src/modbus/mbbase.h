#ifndef MBBASE_H
#define MBBASE_H

#include <map>
#include <deque>
#include <string>
#include <modbus/modbus.h>
#include <srlogger.h>

class ModbusModel
{
public:

    ModbusModel()
    {
    }

    virtual ~ModbusModel()
    {
    }

    void addAddress(uint8_t type, uint16_t address);

    using Model = std::deque<std::pair<uint16_t, uint16_t>>;
    Model comodel;
    Model dimodel;
    Model hrmodel;
    Model irmodel;
};

class ModbusBase
{
public:

    ModbusBase() : ctx(NULL)
    {
        tv.tv_sec = 5;
        tv.tv_usec = 0;
    }

    virtual ~ModbusBase()
    {
        modbus_close(ctx);
        modbus_free(ctx);
    }

    int readCO(int addr, int nb, uint8_t *dest);
    int readDI(int addr, int nb, uint8_t *dest);
    int readHR(int addr, int nb, uint16_t *dest);
    int readIR(int addr, int nb, uint16_t *dest);
    int writeCO(int addr, int status);
    int writeHR(int addr, int status);
    int updateCO(int slave, int addr, int status);
    int updateHRBits(int slave, int addr, const char *v, int sb, int nb,
                     int littleEndian);

    void setTimeout(long usec)
    {
        tv.tv_sec = usec / 1000000;
        tv.tv_usec = usec % 1000000;
    }

    long timeout() const
    {
        return tv.tv_sec * 1000000 + tv.tv_usec;
    }

    std::string errMsg()
    {
        return errmsg + modbus_strerror(errno);
    }

    int getCoilValue(int type, int index) const;
    std::string getRegValue(int type, int index, int startBit, int noBits,
                            int isSigned, int littleEndian) const;

    int size(int type) const
    {
        switch (type)
        {
        case 0:
            return coData.size();
        case 1:
            return diData.size();
        case 2:
            return hrData.size();
        case 3:
            return irData.size();
        default:
            return 0;
        }
    }

    int setSlave(int slave);
    int connect();

    void close()
    {
        modbus_close(ctx);
    }

    int poll(int slave, const ModbusModel *model);

protected:

    void init()
    {
        modbus_set_error_recovery(ctx, MODBUS_ERROR_RECOVERY_PROTOCOL);
#if LIBMODBUS_VERSION_MINOR == 0 || LIBMODBUS_VERSION_MICRO == 1
        const struct timeval tv =
        { 1, 0 };
        modbus_set_byte_timeout(ctx, &tv);
#else
        modbus_set_byte_timeout(ctx, 1, 0);
#endif
#ifdef DEBUG
        modbus_set_debug(ctx, TRUE);
#endif
    }

    modbus_t *ctx;

private:

        struct timeval tv;
        std::map<int, uint8_t> coData;
        std::map<int, uint8_t> diData;
        std::map<int, uint16_t> hrData;
        std::map<int, uint16_t> irData;
        std::string errmsg;
};

class ModbusRTU: public ModbusBase
{
public:
    ModbusRTU(const char *device, int baud, char par, int data, int stop) : ModbusBase()
    {
        srInfo(
                std::string("Modbus: new RTU ") + device + " "
                        + std::to_string(baud) + " " + par
                        + std::to_string(data) + ":" + std::to_string(stop));
        ctx = modbus_new_rtu(device, baud, par, data, stop);
        init();
    }

    void setConf(const char *dev, int baud, char par, int data, int stop)
    {
        modbus_free(ctx);
        srInfo(
                std::string("Modbus: RTU setConf: ") + dev + " "
                        + std::to_string(baud) + " " + par
                        + std::to_string(data) + ":" + std::to_string(stop));
        ctx = modbus_new_rtu(dev, baud, par, data, stop);
        init();
    }
};

class ModbusTCP: public ModbusBase
{
public:
    ModbusTCP(const char *ip, int port) : ModbusBase()
    {
        srInfo(
                std::string("Modbus: new TCP ") + ip + ":"
                        + std::to_string(port));
        ctx = modbus_new_tcp(ip, port);
        init();
    }
};

#endif /* MBBASE_H */
