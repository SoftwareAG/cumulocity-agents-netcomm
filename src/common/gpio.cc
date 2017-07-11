#include <ctime>
#include "gpio.h"

using namespace std;

// Tolerance for converting analogue to digital [voltage]
static const string prefix = "sys.sensors.io.";
static const string c8y = "service.cumulocity.";
static const string keyPullup = "sys.sensors.iocfg.pull_up_voltage";
static const uint8_t tolerance = 1;

static GPIO::Mode str2mode(const string &p)
{
    if (p == "virtual_digital_input")
    {
        return GPIO::VirtualDigitalIn;
    }
    else if (p == "digital_input")
    {
        return GPIO::DigitalInput;
    }
    else if (p == "analogue_input")
    {
        return GPIO::AnalogueInput;
    }
    else if (p == "digital_output")
    {
        return GPIO::DigitalOutput;
    }
    else
    {
        return GPIO::Unknown;
    }
}

string GPIO::alarmText() const
{
    const string s = rdb.get(c8y + _key + ".alarm.text");
    return !s.empty() ? s : _name + " is active";
}

string GPIO::alarmSeverity() const
{
    const string s = rdb.get(c8y + _key + ".alarm.severity");
    return !s.empty() ? s : "MAJOR";
}

GPIO::NotifyMode GPIO::notifyMode() const
{
    const string s = rdb.get(c8y + _key + ".notify");
    if (s == "alarm")
    {
        return Alarm;
    }
    else
    {
        return s == "measurement" ? Measurement : Off;
    }
}

int GPIO::poll()
{
    _mode = str2mode(rdb.get(prefix + _pin + ".mode"));
    va = strtof(rdb.get(prefix + _pin + ".adc").c_str(), NULL);
    float pu = 0;

    switch (_mode)
    {
    case DigitalInput:
    case VirtualDigitalIn:
        vd = strtoul(rdb.get(prefix + _pin + ".d_in").c_str(), NULL, 10);
        break;
    case AnalogueInput:
        pu = strtof(rdb.get(keyPullup).c_str(), NULL);
        vd = va + tolerance >= pu;
        break;
    case DigitalOutput:
        vd = strtoul(rdb.get(prefix + _pin + ".d_out").c_str(), NULL, 10);
        break;
    default:
        vd = 0;
    }

    return _mode == Unknown ? -1 : 0;
}

int GPIO::debounce()
{
    if (_state == DEB_CLEAR && v0 != vd)
    {
        v0 = vd;
        _state = DEB_APPRAISAL;
        clock_gettime(CLOCK_MONOTONIC, &t);
    } else if (_state == DEB_APPRAISAL)
    {
        if (v0 != vd)
        {
            _state = DEB_CLEAR;
            v0 = vd;
        } else
        {
            timespec t1;
            clock_gettime(CLOCK_MONOTONIC, &t1);
            const string s = rdb.get(c8y + _key + ".debounce.interval");
            if (t1.tv_sec - t.tv_sec > strtol(s.c_str(), NULL, 10))
            {
                _state = DEB_CONFIRM;
            }
        }
    }

    return 0;
}
