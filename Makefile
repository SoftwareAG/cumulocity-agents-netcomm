BUILD:=debug
BIN_DIR:=bin
PKG_DIR:=build
SRC_DIR:=src
BUILD_DIR:=build
SR_SSL_CACERT=/usr/local/ssl/certs/ca-cumulocity.pem

COMMON_SRC:=$(wildcard $(SRC_DIR)/common/*.cc)
MODULE_SRC:=$(wildcard $(SRC_DIR)/module/*.cc)
MODBUS_SRC:=$(wildcard $(SRC_DIR)/modbus/*.cc)

C8Y_NTC_PKG_DIR:=build/staging/c8yntcagent
CAFILE:=misc/certs/cacert.pem
CA_DIR:=misc/certs/cacert.d

NTC_BIN:=ntcagent
NTC_SRC:=$(wildcard $(SRC_DIR)/*.cc) $(MODBUS_SRC) $(COMMON_SRC) $(MODULE_SRC)
NTC_OBJ:=$(addprefix $(BUILD_DIR)/,$(NTC_SRC:.cc=.o))
NTC_PKG_DIR:=build/staging/ntcagent

SMS_BIN:=smsagent
SMS_SRC:=$(wildcard $(SRC_DIR)/smsagent/*.cc) $(COMMON_SRC)
SMS_OBJ:=$(addprefix $(BUILD_DIR)/,$(SMS_SRC:.cc=.o))
SMS_PKG_DIR:=build/staging/smsagent

VNC_BIN:=vncproxy
VNC_SRC:=$(wildcard $(SRC_DIR)/vnc/*.c)
VNC_OBJ:=$(addprefix $(BUILD_DIR)/,$(VNC_SRC:.c=.o))
VNC_PKG_DIR:=build/staging/vncproxy

SIGN_PUBKEY:=misc/ipkkeys/cumulocity-public.pem
SIGN_PRIKEY:=misc/ipkkeys/cumulocity-private.pem
SIGN_PKG_DIR:=build/staging/ipksignature

PKG:=$(NTC_SDK_PATH)/tools/mkipk.sh
CC:=$(NTC_SDK_PATH)/compiler/bin/arm-ntc-linux-gnueabi-gcc
CXX:=$(NTC_SDK_PATH)/compiler/bin/arm-ntc-linux-gnueabi-g++
CPPFLAGS:=-I$(NTC_SDK_PATH)/libstage/include -I$(C8Y_LIB_PATH)/include
CPPFLAGS+=-I$(SRC_DIR) -DSR_SSL_CACERT='"$(SR_SSL_CACERT)"'
CXXFLAGS:=-Wall -pedantic -Wextra -Wno-ignored-qualifiers -std=c++11 -MMD
LDFLAGS:=-Llib -L$(NTC_SDK_PATH)/libstage/lib
LDFLAGS+=-Wl,-rpath-link,$(NTC_SDK_PATH)/libstage/lib
LDLIBS:=-l:librdb.so.1

ifeq ($(BUILD), release)
CPPFLAGS+=-DNDEBUG -DLOG_TO_FILE
CXXFLAGS+=-O2
CFLAGS+=-O2
LDFLAGS+=-O2 -s -flto
else
CPPFLAGS+=-DDEBUG
CXXFLAGS+=-O0 -g
CFLAGS+=-O0 -g
LDFLAGS+=-O0 -g
endif

.PHONY: all release clean

all: $(BIN_DIR)/$(NTC_BIN) $(BIN_DIR)/$(VNC_BIN)
	@mkdir -p $(C8Y_NTC_PKG_DIR)/usr/local/bin $(C8Y_NTC_PKG_DIR)/CONTROL
	@mkdir -p $(C8Y_NTC_PKG_DIR)/usr/local/ntcagent
	@mkdir -p $(C8Y_NTC_PKG_DIR)/etc/init.d/rc.d
	@mkdir -p $(C8Y_NTC_PKG_DIR)/etc/cdcs/conf/mgr_templates/
	@mkdir -p $(C8Y_NTC_PKG_DIR)/usr/local/ssl/certs/
	@mkdir -p $(C8Y_NTC_PKG_DIR)/etc/cdcs/conf/pubkey
	@cp scripts/ntcagent.sh $(C8Y_NTC_PKG_DIR)/etc/init.d/rc.d
	@cp scripts/vncproxy.sh $(C8Y_NTC_PKG_DIR)/etc/init.d/rc.d
	@cp scripts/ntcagent.template $(C8Y_NTC_PKG_DIR)/etc/cdcs/conf/mgr_templates/
	@cp -r www $(C8Y_NTC_PKG_DIR)/
	@cp $^  $(C8Y_NTC_PKG_DIR)/usr/local/bin
	@cp $(BIN_DIR)/srwatchdogd $(C8Y_NTC_PKG_DIR)/usr/local/bin/
	@cp -rP lib $(C8Y_NTC_PKG_DIR)/usr/local/
	@cp -r srtemplate.txt lua $(C8Y_NTC_PKG_DIR)/usr/local/ntcagent
	@cp debian/c8yntcagent/* $(C8Y_NTC_PKG_DIR)/CONTROL
	@cp $(CAFILE) $(C8Y_NTC_PKG_DIR)$(SR_SSL_CACERT)
ifneq (,$(wildcard $(CA_DIR)/*))
	@cat $(wildcard $(CA_DIR)/*) >> $(C8Y_NTC_PKG_DIR)$(SR_SSL_CACERT)
endif
ifeq (,$(wildcard $(SIGN_PUBKEY)))
	@echo "Wairning: No public key generated. Run make signature first. It will create a package without public key."
else
	@cp $(SIGN_PUBKEY) $(C8Y_NTC_PKG_DIR)/etc/cdcs/conf/pubkey
endif
	@$(PKG) $(shell pwd)/$(C8Y_NTC_PKG_DIR) $(shell pwd)/$(PKG_DIR)

release:
	@make -s "BUILD=release"

ntc: $(BIN_DIR)/$(NTC_BIN)
	@mkdir -p $(NTC_PKG_DIR)/usr/local/bin $(NTC_PKG_DIR)/CONTROL
	@mkdir -p $(NTC_PKG_DIR)/usr/local/ntcagent
	@mkdir -p $(NTC_PKG_DIR)/etc/init.d/rc.d
	@mkdir -p $(NTC_PKG_DIR)/etc/cdcs/conf/mgr_templates/
	@cp scripts/ntcagent.sh $(NTC_PKG_DIR)/etc/init.d/rc.d
	@cp scripts/ntcagent.template $(NTC_PKG_DIR)/etc/cdcs/conf/mgr_templates/
	@cp -r www $(NTC_PKG_DIR)/
	@cp $<  $(NTC_PKG_DIR)/usr/local/bin
	@cp $(BIN_DIR)/srwatchdogd $(NTC_PKG_DIR)/usr/local/bin/
	@cp -rP lib $(NTC_PKG_DIR)/usr/local/
	@cp -r srtemplate.txt lua $(NTC_PKG_DIR)/usr/local/ntcagent
	@cp debian/ntcagent/* $(NTC_PKG_DIR)/CONTROL
	@$(PKG) $(shell pwd)/$(NTC_PKG_DIR) $(shell pwd)/$(PKG_DIR)

sms: $(BIN_DIR)/$(SMS_BIN)
	@mkdir -p $(SMS_PKG_DIR)/usr/local/bin $(SMS_PKG_DIR)/CONTROL
	@mkdir -p $(SMS_PKG_DIR)/etc/init.d/rc.d
	@cp $< $(SMS_PKG_DIR)/usr/local/bin
	@cp scripts/smsagent_cleanup.sh $(SMS_PKG_DIR)/usr/local/bin
	@cp scripts/smsagent.sh $(SMS_PKG_DIR)/etc/init.d/rc.d
	@cp debian/smsagent/* $(SMS_PKG_DIR)/CONTROL
	@$(PKG) $(shell pwd)/$(SMS_PKG_DIR) $(shell pwd)/$(PKG_DIR)

vnc: $(BIN_DIR)/$(VNC_BIN)
	@mkdir -p $(VNC_PKG_DIR)/usr/local/bin $(VNC_PKG_DIR)/CONTROL
	@mkdir -p $(VNC_PKG_DIR)/etc/init.d/rc.d
	@cp $< $(VNC_PKG_DIR)/usr/local/bin
	@cp scripts/vncproxy.sh $(VNC_PKG_DIR)/etc/init.d/rc.d
	@cp debian/vncproxy/* $(VNC_PKG_DIR)/CONTROL
	@$(PKG) $(shell pwd)/$(VNC_PKG_DIR) $(shell pwd)/$(PKG_DIR)

signature:
	@mkdir -p $(SIGN_PKG_DIR)/CONTROL
	@mkdir -p $(SIGN_PKG_DIR)/etc/cdcs/conf/pubkey
	@mkdir -p misc/ipkkeys
ifeq (,$(wildcard $(SIGN_PUBKEY)))
	@openssl genpkey -algorithm RSA -pkeyopt rsa_keygen_bits:2048 -out $(SIGN_PRIKEY)
	@openssl rsa -in misc/ipkkeys/cumulocity-private.pem -pubout -out $(SIGN_PUBKEY)
else
	@echo "Public key already exists, won't create a new key pair"
endif
	@cp debian/ipksignature/* $(SIGN_PKG_DIR)/CONTROL
	@cp $(SIGN_PUBKEY) $(SIGN_PKG_DIR)/etc/cdcs/conf/pubkey
	@$(PKG) $(shell pwd)/$(SIGN_PKG_DIR) $(shell pwd)/$(PKG_DIR)

$(BIN_DIR)/$(NTC_BIN): $(NTC_OBJ)
	@mkdir -p $(BIN_DIR)
	@echo "(LD) $@"
	@$(CXX) $(LDFLAGS) $^ $(LDLIBS) -lsera -pthread -lmodbus -llua -o $@

$(BIN_DIR)/$(SMS_BIN): $(SMS_OBJ)
	@mkdir -p $(BIN_DIR)
	@echo "(LD) $@"
	@$(CXX) $(LDFLAGS) $^ $(LDLIBS) -o $@

$(BIN_DIR)/$(VNC_BIN): $(VNC_OBJ)
	@mkdir -p $(BIN_DIR)
	@echo "(LD) $@"
	@$(CC) $(LDFLAGS) $^ $(LDLIBS) -lcurl -o $@

$(BUILD_DIR)/%.o: %.cc
	@mkdir -p $(dir $@)
	@echo "(CXX) $@"
	@$(CXX) $(CPPFLAGS) $(CXXFLAGS) $< -c -o $@

$(BUILD_DIR)/%.o: %.c
	@mkdir -p $(dir $@)
	@echo "(CC) $@"
	@$(CXX) $(CPPFLAGS) $(CFLAGS) $< -c -o $@

clean:
	@rm -rf build/*
	@rm -f $(BIN_DIR)/$(SMS_BIN) $(BIN_DIR)/$(NTC_BIN) $(BIN_DIR)/$(VNC_BIN)

-include $(NTC_OBJ:.o=.d)
-include $(SMS_OBJ:.o=.d)
-include $(VNC_OBJ:.o=.d)
