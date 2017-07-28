#include <unistd.h>
#include <srnethttp.h>
#include <srutils.h>
#include "integrate.h"

using namespace std;

namespace
{
const char* const key = "service.cumulocity.connection.password";
}

int Integrate::integrate(const SrAgent &agent, const string &srv, const string &srt)
{
    SrNetHttp http(agent.server() + "/s", srv, agent.auth());
    http.setTimeout(60);
    int c = -1;

    while (c == -1)
    {
        wdt.kick();
        sleep(2);

        if (registerSrTemplate(http, xid, srt) == -1)
        {
            if (http.response().compare(0, 8, "50,1,401") == 0)
            {
                rdb.set(key, "");
                return -1;
            }

            continue;
        }

        http.clear();
        if (http.post("300," + agent.deviceID()) <= 0)
        {
            continue;
        }

        SmartRest sr(http.response());
        SrRecord r = sr.next();
        if (r.size() && r[0].second == "50")
        { // MO not found
            http.clear();

            const string model = rdb.get("uboot.hw_id");
            if (http.post("301,\"" + model + " (S/N " + rdb.get("uboot.sn") + ")\",20") <= 0)
            {
                continue;
            }

            sr.reset(http.response());
            r = sr.next();
            if (r.size() == 3 && r[0].second == "801")
            {
                id = r[2].second;
                string s = "302," + id + "," + agent.deviceID();
                s += "\n320," + id + ",";
                s += model + ",";
                s += agent.deviceID() + ",";
                s += rdb.get("uboot.hw_ver");
                c = http.post(s) <= 0 ? -1 : 0;
            }
        } else if (r.size() == 3 && r[0].second == "800")
        {
            id = r[2].second;
            c = 0;
        }
    }

    return 0;
}
