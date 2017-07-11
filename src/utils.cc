#include "srutils.h"
#include "utils.h"

using namespace std;

static const string padding = "fN4\x1bq8!7n\n13Q$8f";
static const string key = "\x21\x63\x0e\x30\x2f\x1b\x9a\xc2\x34\x55\xe8\x7d\x32\xda\x30\xea\x59";

string mangle(const string& clear)
{
    string text = string(1, clear.size()) + clear;

    if (clear.size() < 16)
    {
        text += padding.substr(0, 16 - clear.size());
    }

    for (size_t i = 0; i < text.size(); ++i)
    {
        text[i] ^= key[i % key.size()];
    }

    return "*1*" + b64Encode(text) + "*";
}

string demangle(const string& cipher)
{
    if (cipher.size() < 5)
    {
        return cipher;
    }

    string text = b64Decode(cipher.substr(3, cipher.size() - 4));
    for (size_t i = 0; i < text.size(); ++i)
    {
        text[i] ^= key[i % key.size()];
    }

    size_t s = text[0];

    return text.substr(1, s);
}
