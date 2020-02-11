# Cumulocity Netcomm Agent #

Cumulocity NetComm Agent is a dedicated agent software for connecting the NetComm router to Cumulocity.

### Supported NetComm Device ###
NTC-220 series

For NTC-6200 and NTC-140W, move to [our NTC-6200 branch](https://bitbucket.org/m2m/cumulocity-agents-netcomm/src/NTC-6200/).


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

* Build the cumulocity-ntc-agent:

```
#!bash

# build in debug mode and logs to stdout.
make
# build in release mode and logs to file
make BUILD=release
```
The cumulocity-ntc-agent will contain agent, CA root certificate (and a package public key if you generated a key pair beforehand)

* Generate a package key pair:

```
#!bash

make signature
```

### FAQ ###

* Installation of IPK file failed because of missing the package sigunature. How can I fix it?

1) Disable the package signature check on your NetComm device by navigating to System > System Configuration > Firmware signature.

2) (**Recommended**) Prepare a signature key pair and build a signed package with the following instruction.

First, let's generate a public/private key pair.

```
#!bash

make signature
```
Note: you need to disable Firmware signature on your NetComm device when you install any package for the first time.

Then, add signature (paired-private key) to cumulocity-ntc-agent package. In the root directory, for example, if you want to add signature to `cumulocity-ntc-agent_1.0.0_arm.ipk`, run:

```
#!bash

./tools/mk-signed-ipk.sh build/cumulocity-ntc-agent_1.0.0_arm.ipk
```
Then, you have just created `cumulocity-ntc-agent_1.0.0_arm-signed.ipk` in build directory. You can install the signed packages even if Firmware signature is enabled as long as the corresponded paired public key exists on your NetComm device.

* How can I query the current package version?

```
#!bash

./version.sh ask
```

* How can I change the cumulocity-ntc-agent version number?

```
#!bash

./version.sh update <new version number>
```

* How do I get the latest CA certificate for verifying server TLS certificate?

In the root directory, run:
```bash
./tools/mk-ca-cumulocity.sh update
```

This will retrieve the Mozilla certificate from [https://curl.haxx.se](https://curl.haxx.se). For more information about the `mk-ca-cumulocity.sh` script, please check its usage by directly running the command without any arguments.

* My server's certificate is not issued by a root CA that's included in the Mozilla bundle, how can I add it?

Copy your root CA certificate to directory `./misc/certs/cacert.d`, then run the above `mk-ca-cumulocity.sh` command. This will append your root CA certificate to the Mozilla bundle.

*Note*: your root CA certificate must be .pem format.