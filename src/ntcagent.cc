#include <cstdio>
#include <fstream>
#include <srutils.h>
#include <srwatchdogtimer.h>
#include <srreporter.h>
#include "modeswitcher.h"
#include "udpalarm.h"
#include "bootstrap.h"
#include "integrate.h"
#include "gpiomanager.h"
#include "rdbmonitor.h"
#include "luamanager.h"
#include "module/vnchandler.h"

#define Q(x) ",\"\""#x"\"\""
#define Q2(x) "\"\""#x"\"\""

using namespace std;

const char* const srTemplatePath = "/usr/local/ntcagent/srtemplate.txt";
const string luaScriptPath = "/usr/local/ntcagent/lua/";
const string keyServer = "service.cumulocity.connection.server";
const string keyLuaPlugin = "service.cumulocity.lua.plugins";
const string keyGpioList = "service.cumulocity.gpio.list";
const string keyStatus = "service.cumulocity.agent.status";

// supported operations
string ops = "\"" Q2(c8y_Configuration) Q(c8y_Restart) Q(c8y_Command)

Q(c8y_LogfileRequest) Q(c8y_SoftwareList) Q(c8y_ModbusDevice)
Q(c8y_Firmware) Q(c8y_SetRegister) Q(c8y_MeasurementRequestOperation)
Q(c8y_SetCoil) Q(c8y_RemoteAccessConnect) Q(c8y_Network.c8y_WAN)
Q(c8y_Network.c8y_LAN) Q(c8y_Network.c8y_DHCP) Q(c8y_RelayArray)
Q(c8y_MeasurementPollFrequencyOperation) Q(c8y_UploadRDB)
Q(c8y_SendConfiguration) Q(c8y_UploadConfigFile)
Q(c8y_DownloadConfigFile) Q(c8y_ModbusConfiguration);

static int integrate(SrAgent &agent, RdbManager &rdb);
static string getServer(const string &s);
static void loadConfig(RdbManager &rdb);


int main()
{
#ifdef LOG_TO_FILE
    srLogSetDest("/opt/ntcagent.log");
#endif

    RdbManager rdb;
    loadConfig(rdb);
    monitor(rdb, NULL);

    // start watchdog
    srInfo("Starting watchdog...");

    SrWatchdogTimer wdt;
    if (wdt.start() == -1)
    {
        srWarning("Start watchdog failed.");
    }

    // get server string from realtime database
    const string server = getServer(rdb.get(keyServer));

    if (server.empty())
    {
        srCritical("Server not specified!");

        // update agent status in realtime database
        rdb.set(keyStatus, "No server URL");

        return 0;
    }

    // update agent status in realtime database
    rdb.set(keyStatus, "Checking network connection and NTP synchronisation");

    srDebug("Checking network connection and NTP synchronisation...");

    // need to wait until WWAN connection is up and if enabled, NTP synchronisation is done.
    // When the agent starts before NTP synch is done, the secure TCP connection used for the PushService is broken and
    // agent does not get any server commands until first heartbeat is missed and re-connection is triggered.
    while (rdb.get("wwan.0.connection.status") != "up" || ((rdb.get("service.ntp.enable") == "1") && (rdb.get("system.ntp.time") == "")))
    {
        wdt.kick();
        sleep(2);
    }

    const string deviceID = rdb.get("uboot.sn");
    Bootstrap boot(server, deviceID, rdb, wdt);
    Integrate igt(rdb, wdt);
    SrAgent agent(server, deviceID, &igt, &boot);
    RdbMonitor monitor(rdb, agent, wdt);

    if (integrate(agent, rdb) == -1)
    {
        srCritical("Integrate failed.");

        // update agent status in realtime database
        rdb.set(keyStatus, "Integrate failed");

        return 0;
    }

    srInfo(string("Device ID: ") + agent.deviceID() + ", ID: " + agent.ID());
    srNotice(string("XID: ") + agent.XID());

    // get NetCom device id
    if (rdb.get("uboot.hw_id") == "NTC-140W-02")
    {
        ops += "\"";
    }
    else
    {
        ops += Q(c8y_SerialConfiguration) "\"";
    }

    agent.send("327," + agent.ID() + "," + ops);
    agent.send("323," + agent.ID());
    agent.send("311," + agent.ID() + ",ACTIVE");
    agent.send("311," + agent.ID() + ",ACKNOWLEDGED");

    // update agent status in realtime database
    rdb.set(keyStatus, "Loading plugins");

    // load lua plugin's
    LuaManager lua(agent);
    lua.addLibPath(luaScriptPath + "?.lua");
    lua.load(luaScriptPath + "shell.lua");
    lua.load(luaScriptPath + "config.lua");
    {
        istringstream iss(rdb.get(keyLuaPlugin));
        for (string sub; getline(iss, sub, ',');)
        {
            if (sub != "shell" && sub != "config")
            {
                lua.load(luaScriptPath + sub + ".lua");
            }
        }
    }

    GPIOManager gm(rdb.get(keyGpioList), rdb, agent);
    UdpAlarm ua(agent, rdb);
    VncHandler vnc(agent);
    SrReporter *rpt = nullptr;
    SrDevicePush *push = nullptr;

    if (rdb.get("service.cumulocity.mqtt.enable") == "1")
    {
        const bool isssl = server.substr(0, 5) == "https";
        const string port = isssl ? ":8883" : ":1883";

        rpt = new SrReporter(server + port, agent.deviceID(), agent.XID(),
                agent.tenant() + '/' + agent.username(), agent.password(),
                agent.egress, agent.ingress, 10000, "/opt/ntcagent/msg.cache");

        string keepalive = rdb.get("service.cumulocity.mqtt.keepalive");
        const int keepAlive = strtol(keepalive.c_str(), NULL, 10);

        rpt->mqttSetOpt(SR_MQTTOPT_KEEPALIVE, keepAlive);
    } else
    {
        agent.send("314," + agent.ID() + ",PENDING");

        rpt = new SrReporter(server, agent.XID(), agent.auth(), agent.egress, agent.ingress, 10000, "/opt/ntcagent/msg.cache");
        push = new SrDevicePush(server, agent.XID(), agent.auth(), agent.ID(), agent.ingress);
    }

    monitor.setReporter(rpt);
    ModeSwitcher switcher(rdb, rpt, nullptr, agent);
    if (rpt->start())
    {
        // update agent status in realtime database
        rdb.set(keyStatus, "Start reporter failed");

        return 0;
    }

    if (push && push->start())
    {
        // update agent status in realtime database
        rdb.set(keyStatus, "Start device push failed");

        return 0;
    }

    // update agent status in realtime database
    rdb.set(keyStatus, "Connected");

    // enter main loop (never returns)
    agent.loop();

    return 0;
}

static int integrate(SrAgent &agent, RdbManager &rdb)
{
    const char* const prefix = "service.cumulocity.connection";

    srInfo("Bootstrap to " + agent.server());

    // update agent status in realtime database
    rdb.set(keyStatus, "Bootstrapping");

    if (agent.bootstrap(prefix))
    {
        srCritical("Bootstrap failed.");
        return -1;
    }

    srInfo("Credential: " + agent.tenant() + "/" + agent.username() + ":" + agent.password());

    // update agent status in realtime database
    rdb.set(keyStatus, "Integrating");

    srDebug("Read SmartRest template...");

    string srv, srt;
    if (readSrTemplate(srTemplatePath, srv, srt))
    {
        srCritical("Read SmartRest failed.");
        return -1;
    }

    srInfo("Integrating");

    if (agent.integrate(srv, srt) == 0)
    {
        return 0;
    }

    if (!rdb.get("service.cumulocity.connection.password").empty())
    {
        return -1;
    }

    srInfo("Invalid credentials, bootstrap again...");

    // update agent status in realtime database
    rdb.set(keyStatus, "Bootstrapping");

    if (agent.bootstrap(prefix))
    {
        srCritical("Bootstrap failed.");
        return -1;
    }

    srInfo("Credential: " + agent.tenant() + "/" + agent.username() + ":" + agent.password());

    // update agent status in realtime database
    rdb.set(keyStatus, "Integrating");

    return agent.integrate(srv, srt);
}

static string getServer(const string &s)
{
    size_t pos = s.size();

    if (s.size() < 3)
    {
        pos = pos;
    }
    else if (s.compare(s.size() - 2, 2, "/s") == 0)
    {
        pos -= 2;
    }
    else if (s.back() == '/')
    {
        --pos;
    }

    return s.substr(0, pos);
}

static void loadConfig(RdbManager &rdb)
{
    const char* const configPath = "/opt/ntcagent/config.save";
    ifstream in(configPath);

    if (!in)
    {
        return;
    }

    for (string line; getline(in, line);)
    {
        const size_t pos = line.find(' ');
        if (pos != string::npos)
        {
            const string key = line.substr(0, pos);
            const string value = line.substr(pos + 1);
            if (rdb.set(key, value))
            {
                rdb.create(key, value, PERSIST);
            }
        }
    }

    remove(configPath);
}