#include <inttypes.h>
#include <iomanip>
#include <sstream>
#include "mbbase.h"

using namespace std;

static const char *FNAMES[] = { "RD_CO ", "RD_DI ", "RD_HR ", "RD_IR ", "WR_CO ", "WR_HR " };

static string pf(int fc, int addr, int nb)
{
    return FNAMES[fc] + to_string(addr) + " " + to_string(nb);
}

static int comm(modbus_t *ctx, int c, int addr, int nb, void *d, string &emsg)
{
    srDebug("Modbus: " + pf(c, addr, nb));

    uint8_t *d1 = (uint8_t*) d;
    uint16_t *d2 = (uint16_t*) d;
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
                if (srLogIsEnabledFor(SRLOG_DEBUG))
                {
                    for (auto i = 0; i < ret; ++i)
                    {
                        debug << '<' << setw(2) << setfill('0') << hex << int(d1[i]) << '>';
                    }
                    srDebug(debug.str());
                }
                break;
            case 2:
            case 3:
                if (srLogIsEnabledFor(SRLOG_DEBUG))
                {
                    for (auto i = 0; i < ret; ++i)
                    {
                        debug << '<' << setw(4) << setfill('0') << hex << int(d2[i]) << '>';
                    }
                    srDebug(debug.str());
                }
                break;

            default:
            {
                break;
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

    if (pm->empty()) {
        pm->emplace_back(addr, addr);
        return;
    }

    // Make a pair (start addr, end addr) to queue
    for(auto itr = pm->begin(); itr != pm->end(); ++itr) {
        if (itr->first <= addr && addr <= itr->second){
            // addr is within the pair's address range
            return;
        } else if (itr->second + 1 == itr->first + limit) {
            // The pair's address range is already limit
            continue;
        } else if (itr->second + 2 == itr->first + limit) {
            // The pair's address range will be limit after extension
            if (addr + 1 == itr->first) {
                itr->first = addr;
                return;
            } else if (addr == itr->second + 1) {
                itr->second = addr;
                return;
            }
        } else if (addr + 1 == itr->first) {
            itr->first = addr;
            for(auto i = pm->begin(); i != pm->end(); ++i) {
                // Extend the pair's address range with another consecutive pair
                if (addr == i->second + 1) {
                    itr->first = i->first;
                    pm->erase(i);
                    break;
                }
            }
            return;
        } else if (addr == itr->second + 1){
            itr->second = addr;
            for(auto i = pm->begin(); i != pm->end(); ++i) {
                if (addr + 1 == i->first) {
                    itr->second = i->second;
                    pm->erase(i);
                    break;
                }
            }
            return;
        }
    }
    pm->emplace_back(addr, addr);
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

        struct timeval t
        { 5, 0 };
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
    for (int i = 0; i < N; ++i) {
        const ModbusModel::Model *mod = nullptr;
        switch (i) {
        case 0: mod = &(model->comodel); break;
        case 1: mod = &(model->dimodel); break;
        case 2: mod = &(model->hrmodel); break;
        case 3: mod = &(model->irmodel); break;
        }

        uint8_t bits[MODBUS_MAX_READ_BITS];
        uint16_t regs[MODBUS_MAX_READ_REGISTERS];
        for (const auto& e : *mod) {
            const int addr = e.first;
            const int nb = e.second - e.first + 1;
            int l = 0;

            switch (i) {
                case 0:
                    l = readCO(addr, nb, bits);
                    for (int j = 0; j < l; ++j)
                            coData[addr + j] = bits[j];
                    break;
                case 1:
                    l = readDI(addr, nb, bits);
                    for (int j = 0; j < l; ++j)
                            diData[addr + j] = bits[j];
                    break;
                case 2:
                    l = readHR(addr, nb, regs);
                    for (int j = 0; j < l; ++j)
                        hrData[addr + j] = regs[j];
                    break;
                case 3:
                    l = readIR(addr, nb, regs);
                    for (int j = 0; j < l; ++j)
                        irData[addr + j] = regs[j];
                    break;
                default:
                    break;
            }
            if (l == -1) {
                ret = -1;
                break;
            }
        }
    }
    close();

    return ret;
}


int ModbusBase::updateCO(int slave, int addr, int status)
{
    if (setSlave(slave) == -1) return -1;
    if (connect() == -1) return -1;
    const int ret = writeCO(addr, status);
    close();
    return ret;
}


static uint64_t getValue(uint16_t *buf, int size, int littleEndian)
{
        uint64_t val = 0;
        if (littleEndian) {
                for (int i = size - 1; i >= 0; --i) {
                        uint16_t a = buf[i];
                        a = (a >> 8) + (a << 8);
                        val = (val << 16) + a;
                }
        } else {
                for (int i = 0; i < size; ++i) {
                        val = (val << 16) + buf[i];
                }
        }
        return val;
}


int ModbusBase::updateHRBits(int slave, int addr, const char *val, int sb,
                             int nb, int littleEndian)
{
        int n = (sb + nb - 1) / 16 + 1;
        uint16_t resp[4] = {0};
        uint64_t v = 0;
        sscanf(val, "%" SCNu64, &v);
        if (setSlave(slave) == -1) return -1;
        if (connect() == -1) return -1;
        if (readHR(addr, n, resp) == -1) return -1;

        uint64_t status = getValue(resp, n, littleEndian);
        const uint64_t mask = (0xffffffffffffffff >> (64 - nb)) << sb;
        status = (status & ~mask) | (v << sb);
        if (littleEndian) {
                for (int i = 0; i < n; ++i) {
                        uint16_t a = status & 0xffff;
                        resp[i] = (a >> 8) + (a << 8);
                        status >>= 16;
                }
        } else {
                for (int i = n - 1; i >= 0; --i) {
                        resp[i] = status & 0xffff;
                        status >>= 16;
                }
        }
        int ret = 0;
        for (int i = 0; i < n; ++i)
                ret = writeHR(addr + i, resp[i]);
        close();
        return ret;
}


int ModbusBase::getCoilValue(int type, int index) const
{
        if (type == 0) return coData.at(index);
        else if (type == 1) return diData.at(index);
        else return 0;
}


string ModbusBase::getRegValue(int type, int index, int startBit, int noBits,
                               int isSigned, int littleEndian) const
{
        int n = (startBit + noBits - 1) / 16 + 1;
        const std::map<int, uint16_t> *pData = !type ? &hrData : &irData;
        uint16_t resp[4] = {0};
        for (int i = 0; i < n; ++i)
                resp[i] = pData->at(index + i);
        uint64_t val = getValue(resp, n, littleEndian);
        val >>= startBit;
        const uint64_t mask = 0xffffffffffffffff >> (64 - noBits);
        const uint64_t sign = (val >> (noBits - 1)) & 0x01;
        char buf[256] = {0};
        if (!isSigned) {
                snprintf(buf, sizeof(buf), "%" PRIu64, val & mask);
        } else if (sign) {
                snprintf(buf, sizeof(buf), "-%" PRIu64, (val ^ mask) + 1);
        } else {
                snprintf(buf, sizeof(buf), "%" PRIu64, val & mask);
        }
        return buf;
}
