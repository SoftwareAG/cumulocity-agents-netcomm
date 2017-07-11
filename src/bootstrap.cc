#include <locale>
#include <smartrest.h>
#include <srnethttp.h>
#include "utils.h"
#include "bootstrap.h"

using namespace std;

#define MAX_NUM_OF_CREDENTIALS_REQUESTS 10000


static string getDeviceID(const string &s)
{
    string ret;
    locale loc;

    for (auto e : s)
    {
        if (e != ':')
        {
            ret += tolower(e, loc);
        }
    }

    return ret;
}

int Bootstrap::loadCredential(const string &path)
{
    const string user = rdb.get(path + ".username");
    const size_t pos = user.find('/');

    _tenant = user.substr(0, pos);
    _username = user.substr(pos < user.size() ? pos + 1 : user.size());
    _password = demangle(rdb.get(path + ".password"));
    const bool valid = _tenant.empty() || _username.empty() || _password.empty();

    return valid ? -1 : 0;
}

int Bootstrap::requestCredential()
{
    const char* const auth = "Authorization: Basic bWFuYWdlbWVudC9kZXZpY2Vib290c3RyYXA6RmhkdDFiYjFm";
    const string post = "61," + _deviceID + "\n" + "61," + getDeviceID(rdb.get("systeminfo.mac.eth0"));

    SrNetHttp http(_server.c_str(), "", auth);
    http.setTimeout(60);

    for (int i = 0; i < MAX_NUM_OF_CREDENTIALS_REQUESTS; ++i)
    {
        wdt.kick();

        sleep(2);
        http.clear();

        if (http.post(post) <= 0)
        {
            continue;
        }

        SrParser parser(http.response());
        SrRecord r = parser.next();
        if (r.size() && r[0].second == "70")
        {
            _tenant = r.value(3);
            _username = r.value(4);
            _password = r.value(5);
            return 0;
        }

        r = parser.next();
        if (r.size() && r[0].second == "70")
        {
            _tenant = r.value(3);
            _username = r.value(4);
            _password = r.value(5);
            return 0;
        }
    }

    return -1;
}

int Bootstrap::saveCredential(const string &path)
{
    const string keyUser = path + ".username";
    const string keyPass = path + ".password";
    const string user = _tenant + "/" + _username;

    if (rdb.set(keyUser, user) && rdb.create(keyUser, user, PERSIST))
    {
        return -1;
    }

    if (rdb.set(keyPass, mangle(_password)) && rdb.create(keyPass, mangle(_password), PERSIST | CRYPT))
    {
        return -1;
    }

    return 0;
}
