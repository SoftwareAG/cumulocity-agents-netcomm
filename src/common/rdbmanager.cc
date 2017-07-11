#include "rdbmanager.h"

using namespace std;

int RdbManager::create(const string &k, const string &v, int flags, int perm)
{
    if (s)
    {
        return rdb_create_string(s, k.c_str(), v.c_str(), flags, perm);
    }

    return -1;
}

int RdbManager::remove(const string &k)
{
    if (s)
    {
        return rdb_delete(s, k.c_str());
    }

    return -1;
}

string RdbManager::get(const string &key) const
{
    if (s)
    {
        char v[RDB_VALUE_LEN] = { 0 };
        int n = sizeof(v);

        if (rdb_get(s, key.c_str(), v, &n) == 0)
        {
            return v;
        }
    }

    return "";
}

int RdbManager::set(const string &key, const string &value)
{
    if (s)
    {
        return rdb_set_string(s, key.c_str(), value.c_str());
    }

    return -1;
}
