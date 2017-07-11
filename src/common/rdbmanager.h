#ifndef RDBMANAGER_H
#define RDBMANAGER_H

#include <string>
#include <rdb_ops.h>

#define RDB_VALUE_LEN 100

class RdbManager
{
public:
    using string = std::string;

    RdbManager() : s(NULL)
    {
        if (rdb_open(NULL, &s) < 0)
        {
            s = NULL;
        }
    }

    virtual ~RdbManager()
    {
        rdb_close(&s);
    }

    int create(const string &key, const string &value, int flags = 0, int perm = DEFAULT_PERM);
    int remove(const string &key);
    string get(const string &key) const;
    int set(const string &key, const string &value);

private:

    struct rdb_session *s;
};

#endif /* RDBMANAGER_H */
