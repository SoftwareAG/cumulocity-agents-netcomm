#include <iomanip>
#include <sstream>
#include "mbbase.h"

using namespace std;

static const char *FNAMES[] =
{ "RD_CO ", "RD_DI ", "RD_HR ", "RD_IR ", "WR_CO ", "WR_HR " };

static string pf(int fc, int addr, int nb)
{
    return FNAMES[fc] + to_string(addr) + " " + to_string(nb);
}

static int comm(modbus_t *ctx, int c, int addr, int nb, void *d, string &emsg)
{
    srDebug("Modbus: " + pf(c, addr, nb));

    uint8_t* const d1 = (uint8_t*) d;
    uint16_t* const d2 = (uint16_t*) d;
    int ret = 0;

    switch (c)
    {
    case 0:
        ret = modbus_read_bits(ctx, addr, nb, d1);
        break;
    case 1:
        ret = modbus_read_input_bits(ctx, addr, nb, d1);
        break;
    case 2:
        ret = modbus_read_registers(ctx, addr, nb, d2);
        break;
    case 3:
        ret = modbus_read_input_registers(ctx, addr, nb, d2);
        break;
    case 4:
        ret = modbus_write_bit(ctx, addr, nb);
        break;
    case 5:
        ret = modbus_write_register(ctx, addr, nb);
        break;
    }

    if (ret == -1)
    {
        emsg = pf(c, addr, nb) + " ";
        srError(emsg + modbus_strerror(errno));
    } else
    {
        stringstream debug("modbus: ", ios::out | ios::ate);

        switch (c)
        {
        case 0:
        case 1:
        {
            if (srLogIsEnabledFor(SRLOG_DEBUG))
            {
                for (auto i = 0; i < ret; ++i)
                {
                    debug << '<' << setw(2) << setfill('0') << hex << int(d1[i]) << '>';
                }

                srDebug(debug.str());
            }
            break;
        }
        case 2:
        case 3:
        {
            if (srLogIsEnabledFor(SRLOG_DEBUG))
            {
                for (auto i = 0; i < ret; ++i)
                {
                    debug << '<' << setw(4) << setfill('0') << hex << int(d2[i]) << '>';
                }

                srDebug(debug.str());
            }
        }
        }
    }

    return ret;
}

void ModbusModel::addAddress(uint8_t type, uint16_t addr)
{
    int limit = 0;
    Model *pm = nullptr;

    switch (type)
    {
    case 0:
        pm = &comodel;
        limit = MODBUS_MAX_READ_BITS;
        break;
    case 1:
        pm = &dimodel;
        limit = MODBUS_MAX_READ_BITS;
        break;
    case 2:
        pm = &hrmodel;
        limit = MODBUS_MAX_READ_REGISTERS;
        break;
    case 3:
        pm = &irmodel;
        limit = MODBUS_MAX_READ_REGISTERS;
        break;
    }

    if (pm->empty() || pm->back().second + 1 < addr
            || pm->back().first + limit < addr + 1)
    {
        pm->emplace_back(addr, addr);
    }
    else
    {
        pm->back().second = addr;
    }
}

int ModbusBase::readCO(int addr, int nb, uint8_t *dest)
{
    return comm(ctx, 0, addr, nb, dest, errmsg);
}

int ModbusBase::readDI(int addr, int nb, uint8_t *dest)
{
    return comm(ctx, 1, addr, nb, dest, errmsg);
}

int ModbusBase::readHR(int addr, int nb, uint16_t *dest)
{
    return comm(ctx, 2, addr, nb, dest, errmsg);
}

int ModbusBase::readIR(int addr, int nb, uint16_t *dest)
{
    return comm(ctx, 3, addr, nb, dest, errmsg);
}

int ModbusBase::writeCO(int addr, int status)
{
    return comm(ctx, 4, addr, status, NULL, errmsg);
}

int ModbusBase::writeHR(int addr, int status)
{
    return comm(ctx, 5, addr, status, NULL, errmsg);
}

int ModbusBase::setSlave(int slave)
{
    if (modbus_set_slave(ctx, slave) == -1)
    {
        errmsg = "set_slave() ";
        srError("Modbus: " + errmsg + modbus_strerror(errno));

        return -1;
    }

    return 0;
}

int ModbusBase::connect()
{
#if LIBMODBUS_VERSION_MINOR == 0 || LIBMODBUS_VERSION_MICRO == 1
    modbus_set_response_timeout(ctx, &tv);
#else
    modbus_set_response_timeout(ctx, tv.tv_sec, tv.tv_usec);
#endif

    int ret = modbus_connect(ctx);
    if (ret == -1 && errno == EINPROGRESS)
    {
        const int fd = modbus_get_socket(ctx);
        fd_set wfds;
        FD_ZERO(&wfds);
        FD_SET(fd, &wfds);
        struct timeval t { 5, 0 };

        ret = select(fd + 1, NULL, &wfds, NULL, &t) > 0 ? 0 : -1;
    }

    if (ret == -1)
    {
        errmsg = "connect() ";
        srError("Modbus: " + errmsg + modbus_strerror(errno));
    }

    return ret;
}

int ModbusBase::poll(int slave, const ModbusModel *model)
{
    if (setSlave(slave) == -1)
    {
        return -1;
    }

    if (connect() == -1)
    {
        return -1;
    }

    const int N = 4;
    int ret = 0;
    for (int i = 0; i < N; ++i)
    {
        const ModbusModel::Model *mod = nullptr;
        switch (i)
        {
        case 0:
            mod = &(model->comodel);
            coData.clear();
            break;
        case 1:
            mod = &(model->dimodel);
            diData.clear();
            break;
        case 2:
            mod = &(model->hrmodel);
            hrData.clear();
            break;
        case 3:
            mod = &(model->irmodel);
            irData.clear();
            break;
        }

        uint8_t bits[MODBUS_MAX_READ_BITS];
        uint16_t regs[MODBUS_MAX_READ_REGISTERS];
        for (const auto& e : *mod)
        {
            const int addr = e.first;
            const int nb = e.second - e.first + 1;
            int l = 0;
            switch (i)
            {
            case 0:
                l = readCO(addr, nb, bits);
                for (int j = 0; j < l; ++j)
                    coData.push_back(bits[j]);
                break;
            case 1:
                l = readDI(addr, nb, bits);
                for (int j = 0; j < l; ++j)
                    diData.push_back(bits[j]);
                break;
            case 2:
                l = readHR(addr, nb, regs);
                for (int j = 0; j < l; ++j)
                    hrData.push_back(regs[j]);
                break;
            case 3:
                l = readIR(addr, nb, regs);
                for (int j = 0; j < l; ++j)
                    irData.push_back(regs[j]);
                break;
            }

            if (l == -1)
            {
                ret = -1;
                switch (i)
                {
                case 0:
                    coData.clear();
                    break;
                case 1:
                    diData.clear();
                    break;
                case 2:
                    hrData.clear();
                    break;
                case 3:
                    irData.clear();
                    break;
                }
                break;
            }
        }
    }

    close();

    return ret;
}

int ModbusBase::updateCO(int slave, int addr, int status)
{
    if (setSlave(slave) == -1)
    {
        return -1;
    }

    if (connect() == -1)
    {
        return -1;
    }

    const int ret = writeCO(addr, status);

    close();

    return ret;
}

int ModbusBase::updateHRBits(int slave, int addr, int v, int sb, int nb)
{
    if (setSlave(slave) == -1)
    {
        return -1;
    }

    if (connect() == -1)
    {
        return -1;
    }

    uint16_t status = 0;
    if (readHR(addr, 1, &status) == -1)
    {
        return -1;
    }

    const int a = ~(((1 << nb) - 1) << sb);
    status = (status & a) | (v << sb);
    const int ret = writeHR(addr, status);

    close();

    return ret;
}
