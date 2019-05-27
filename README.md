# Cumulocity Netcomm Agent #

Cumulocity Netcomm agent is a dedicated agent software for connecting the NetComm router to Cumulocity.

### How to build the agent? ###

* Download the agent source code:

```
#!bash

git clone git@bitbucket.org:m2m/cumulocity-agents-netcomm.git
```

* Build the [Cumulocity C++ library](https://bitbucket.org/m2m/cumulocity-sdk-c) with the provided *init.mk* from the repo.
* Copy the compiled library files to the *lib/* directory under the agent root directory.
* Export the Cumulocity C++ library and NetComm SDK path (add the following code to your ~/.bashrc for permanence):

```
#!bash

export C8Y_LIB_PATH=/library/root/path
export NTC_SDK_PATH=/netcomm/sdk/path
```

* Build the ntcagent:

```
#!bash

# build in debug mode and logs to stdout.
make
# build in release mode and logs to file
make BUILD=release
```

* Build the smsagent:

```
#!bash

# build in debug mode
make sms
# build in release mode
make sms BUILD=release
```

### FAQ ###

* How can I query the current package versions?

```
#!bash

./version.sh ask
```

* How can I change the ntcagent version number?

```
#!bash

./version.sh <new version number> -
```

* How can I change the smsagent version number?

```
#!bash

./version.sh - <new version number>
```

* How do I get a CA certificate bundle for verifying server TLS certificate?

In the root directory, run:
```bash
./tools/mk-ca-cumulocity.sh pkg
```

This will package the Mozilla certificate bundle as a .ipk, which can be installed on the NetComm device. For more information about the `mk-ca-cumulocity.sh` script, please check its usage by directly running the command without any arguments.

* My server's certificate is not issued by a root CA that's included in the Mozilla bundle, how can I add it?

Copy your root CA certificate to directory `./misc/certs/cacert.d`, then run the above `mk-ca-cumulocity.sh` command. This will append your root CA certificate to the Mozilla bundle.

*Note*: your root CA certificate must be .pem format.