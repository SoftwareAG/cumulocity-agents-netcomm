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
```
#!bash

cp -rP $C8Y_LIB_PATH/lib $C8Y_LIB_PATH/bin .
```
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

* Installation of IPK file failed because of signature installation. How can I fix it?

There are two ways to fix it.

1) Disable IPK signature checking on your Netcomm device by going to System > System Configuration > Firmware signature.

2) (**Recommended**) Install a signature key on your Netcomm device and build signed package with the following instruction.

First, let's generate public/private key pair and build IPK package contains the public key.

```
#!bash

make signature
```
Note: you need to disable signature validation on your Netcomm device when you install the public key package

Then, add signature (the paired-private key) to each Cumulocity package. In the root directory, run:

```
#!bash

./tools/mk-signed-ipk.sh <path-to-ipk-file>
```
The packages created by this command can be installed even if you enable signature validation checking on your Netcomm device as long as the paired public key is stored there.

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