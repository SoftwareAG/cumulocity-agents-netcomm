#ifndef GPIO_H
#define GPIO_H

#include <string>
#include <cstdint>
#include "rdbmanager.h"

#define DEB_CLEAR 0
#define DEB_APPRAISAL 1
#define DEB_CONFIRM 2

#define pin2name(x) x.compare(0, 4, "xaux") == 0 ? "gpio" + x.substr(4) : x
#define pin2key(x) x.compare(0, 4, "xaux") == 0 ? "gpio." + x.substr(4) : x

class GPIO
{
public:
    enum Mode
    {
        DigitalOutput, AnalogueInput, VirtualDigitalIn, DigitalInput, Unknown
    };

    enum NotifyMode
    {
        Off, Alarm, Measurement
    };

    GPIO(const std::string &pin, const RdbManager &rdb) :
            _pin(pin), _name(pin2name(pin)), _key(pin2key(pin)), va(0), rdb(
                    rdb), _mode(Unknown), _state(DEB_CLEAR), vd(0), v0(2)
    {
    }

    virtual ~GPIO()
    {
    }

    const std::string &name() const
    {
        return _name;
    }

    const std::string &pin() const
    {
        return _pin;
    }

    uint8_t vdigit() const
    {
        return vd;
    }

    float vanalog() const
    {
        return va;
    }

    bool alarm() const
    {
        return _state == DEB_CONFIRM;
    }

    Mode mode() const
    {
        return _mode;
    }

    NotifyMode notifyMode() const;
    std::string alarmText() const;
    std::string alarmSeverity() const;

    int poll();
    int debounce();
    void clear()
    {
        _state = DEB_CLEAR;
    }

private:

    const std::string _pin;
    const std::string _name;
    const std::string _key;
    timespec t;
    float va;
    const RdbManager &rdb;
    Mode _mode;
    uint8_t _state;
    uint8_t vd;
    uint8_t v0;
};

#endif /* GPIO_H */
