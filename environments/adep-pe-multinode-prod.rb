name "adep-new-prod"

description "The new CentOS7 based ADEP PE HA production environment"

default_attributes(
 "elb" => {
      "name" => "production"
    }
)
override_attributes(
  "chef_client" => {
        "server_url" => "https://mdm-adep-mgmnt1.vas.mts.ru"
  },
  "domainname" => "iot.mts.ru",
  'yum' => {
    'repositories' => {
        'cumulocity-testing' => {
            'enabled' => "0"
      },
    'cumulocity' => {
            'url' => "https://cumulocity:ACceP=m+2m@yum.cumulocity.com/centos/7/cumulocity/x86_64/",
            'name' => "cumulocity",
            'description' => "Cumulocity Repository",
            'enabled' => "1",
            'sslverify' => "0"
            }
        }
  },
  "environment" => {
    "address" => "iot.mts.ru"
  },
  "java" => {
     "jdk_version" => "8"
  },
  "nagios" => {
    "users" => {
          "admin_role" => "nagios_admin",
    },
    "server" => {
        "version" => "3.4.3",
        "checksum" => "adb04a255a3bb1574840ebd4a0f2eb76"
        }
    },
  "cumulocity-kubernetes" => {
     "deployK8S4env" => "adep-new-prod",
     "attachedEnvs" => ["adep-new-prod"],
     "token" => "9ie3b0.gav87ibm164rcznt",
     "images-connString" => "https://K8Simages:K8S^imAgEs5000%@resources.cumulocity.com/kubernetes-images",
     "images-version" => "9.0.16",
     "images2install" => [ "cep" ],
     "heapster" => {
       "enabled" => true
     }
  },
  "cumulocity-karaf" => {
    "version" => "9.0.16-1",
    "memory_left_for_system" => "2048",
    "notification" => true,
    "oort-enabled" => true,
    "cep-server-enabled" => true,
    "ssa-version" => "9.0.15-1",
    "CUMULOCITY_LICENCE_KEY" => "515f526a3b2a63b996e7abb85e01eff216897b9c63394e90fb3f4c3e1bcde1522cfadfc8ed5fd37aa577503140b8918355292f0764cc8f09b7256afd151b4acb"
  },
  "cumulocity-core" => {
    "properties" => {
      "contextService.rdbmsURL" => "jdbc:postgresql://localhost",
      "contextService.rdbmsDriver" => "org.postgresql.Driver",
      "contextService.rdbmsUser" => "postgres",
#      "contextService.rdbmsPassword" => "1604",
#      "system.connectivity.microservice.url" => "http://185.150.9.179:8092/jwireless",
      "mongodb.user" => "c8y-root",
#     "mongodb.password" => "1604",
      "mongodb.admindb" => "admin",
      "contextService.tenantManagementDB" => "management",
      "cumulocity.environment" => "PRODUCTION",
      "auth.checkBlockingFromOutside" => false,
      ## c8yiot:18:ADEP
      "default.tenant.applications" => "administration,devicemanagement,cockpit,feature-microservice-hosting,feature-cep-custom-rules",
      "management.admin.password" => "ccd11e04cfc80e7897aed6a16bbec041dbb30087df9986e591845e8eb9b0f4c1",
      "tenant.admin.password" => "ccd11e04cfc80e7897aed6a16bbec041dbb30087df9986e591845e8eb9b0f4c1",
      "admin.password" => "ccd11e04cfc80e7897aed6a16bbec041dbb30087df9986e591845e8eb9b0f4c1",
      "cometd.heartbeat.minutes" => "5",
      "default.tenant.microservices" => "device-simulator, smartrule, cep",
      "system.support-user.enabled" => true,
      "tenantSuspend.mail.sendtosuspended" => false,
      "tenantSuspend.mail.additional.address" => "operations@cumulocity.com",
      "device-simulator.microservice.url" => "http://10.241.41.3:6666",
      "smartrule.microservice.url" => "http://127.0.0.1:8334",
      "microservice.websocket.port" => 8303,
      # Use mongoDB only:
      "migration.tomongo.default" => "MONGO_READ_WRITE",
      "email.from" => "no-reply@iot.mts.ru",
      "errorMessageRepresentationBuilder.includeDebug" => "false",
      "passwordReset.email.subject" => "Password reset",
      "passwordReset.token.email.template" => 'Dear MTS IoT user,\n\n\
            You or someone else entered this email address when trying to change the password of an IoT user.\n\n\
            Please use the following link to reset your password: \n\
            {host}?token={token}&showTenant\n\n\
            If you were not expecting this email, please ignore it. \n\n\
            Kind regards,\n\
            Your MTS IoT support team\n',
      "passwordReset.user.not.found.email.template" => 'Hi there,\n\n\
            you or someone else entered this email address when trying to change the password of an MTS Iot user.\n\n\
            However, we could not find the email address in your account. Please contact the administrator of your \
            account to set your email address and password. If you are the administrator of the account,\
            please use the email address that you registered with.\n\n\
            If you were not expecting this email, please ignore it. In case of questions, please get in contact with the administrator of the MTS Iot portal. \n\n\
            Kind regards,\n\
            The MTS IoT support team\n',
      "passwordReset.success.email.template" => 'Dear MTS IoT user,\n\n\
            Your password on {host} has been recently changed. \n\
            If you or your administrator made this change, you do not need to do anything more. \n\
            If you did not make this change, please contact your administrator.\n\n\
            Kind regards,\n\
            Your MTS IoT support team\n',
      "passwordReset.invite.template" => 'Hi there,\n\n\
            Please use the following link to reset your password: \n\
            {host}/apps/devicemanagement/index.html?token={token}\n\n\
            If you were not expecting this email, please ignore it. \n\n\
            Kind regards,\n\n\
            Your MTS IoT support team\n'
    }
  },
    "cumulocity-mongo" => {
#       'members-check' => false, # default: true
#       "installEnterprise" => true, # migration change
        "wiredtiger-cache" => 2,
        "sharedkey-content" => "c8UOBqDkvD7tihqTWb/lOb5Jz7xiLmTOsnGJME1QUkeGvi6lcEteWOyyJDXR5ecB\nAk7WKFrJ+z9oalQnJdINHAMLKt+btTlB15y1bwQlo2dLfc7p59roUdfLl+OTjsAa\nxyKMc6FqGmxlT55oPD1c0QVMQYOs5Eu7CNrQ5CJn2D3aAN3j5DQk68yjjHgvxghd\nNX5BFJxuWebJygt5JLtptq0ztu54iQpV+dPUNH6TCaGInUCc5NcUsYQ7xCo+UmTb\n66w90erwWnj/KrFH0MYXAadB3l4ih/ERc6WtqgyNQO3qmnG81P5ro0NtTddGFImx\nm3FlxFnXg8/wLRpgKAlQW17DgwpmxqeXs7n8cvMxkngeEqbmLIwNtWIgcqmLbUix\n4zEKZrXDnaTrGb0+Qz2odWYHtd8wo62MywH80NVkYIz+Khvlej6J/onn9oa23gy1\ngCou8z5+GSD2AbdPYjomTF//XsECT69YEuaNlgoW95xTyHoc4XNI6DV8kt45IHWi\n3UkcduYeJIbY1w0Vq/RlUXevn4+EUDyJAnOd3Q4b9ngvnYJcrTSlfV4PlQmZX0PH\n0UwSm8PsBOonudjdNUD1oZwjpTExrsaVfs0YTASsTm4bZnthlekyJgVtfApXMzfr\nilhdHivh8TCIRjtEBUSd3A25U4HGZfuXFMpdVRl0YgaB4p24r3WRJ01XYC9sP9Gz\n1B8BOJJpDI/9X42XMugQkKP98iQF8LzZwgL5aPBl8xDUuypg3JLrq21Cb7QY21/2\nM42wIMOnH3UMUoughxj2p96+jxqoX6WOVsnrzZ1gSSmE7Q0bg5u2Y4934drK7aiy\n7YNmWsCVGrx1VpOUeJgaIcRuHJAznQF4U4033f/y+pQA6LieZBdEly+UyCBTEMOr\nLt4KJGm/CMUdej8NrCVfsOkerINLDU01cKBjNdNPPJ6Ugu6SmNLdiD1awjULkqw5\nanEYyq7+f30u7+L+EGefPNLZvUHB",
        "mongodb.initUser" => "init-root",
        "mongodb.initPassword" => "qtr:18:IoTPE1"
  },
    "cumulocity-external-lb" => {
        "landing_page" => "https://iotsolutionbuilder.a1.qa/apps/devicemanagement",
        "paas_default_page" => "https://$http_host/apps/$defapp/",
        "paas_public_default_page" => "https://iotsolutionbuilder.a1.qa/apps/dmpublic",
        "usePostgresForPaaS" => false,
        "paas_redirection" => true,
        "proxy_cache" => true,
        "useIPAddress" => true,
        "useMQTTsupport" => true,
        "useKarafWebsocket" => true,
        "useSSL" => true,
        ##"certificate_domain" => "acme.com",
        "certificate_domain" => "cumulocity.com",
        "temp_chunkin" => false,
        "useLUAforSSLcerts" => nil,
        "useLUAforLimits" => true,
        "nginx" => {
            "NGinxPort" => "openresty",
             "version" => "1.11.2.4-20.el7.centos.c8y.8.11.1" # migration change
        }
  },
#    'cumulocity-rsyslog' => {
#      'cross-env-log-server' => "mdm-adep-graylog1",
#      'log-server-ext-address' => "mdm-adep-graylog1.vas.mts.ru"
#  },
   "cumulocity-cep" => {
       "properties" => {
         " esperha.storage" => "/mnt/esperha-storage/"
     },
  },

#   "cumulocity-ssagents" => {
#        "scriptDir" => "/root",
#        "useTags" => true,
#        "ssAgentsIP" => "185.150.9.179",
#          },

  'monit' => {
    'mongo' => {
      'checkAltPort' => false
     },
      'cep' => {
        'reaction' => 'alert'
     },
      'karaf' => {
        'reaction' => 'alert'
     }
  }

)

#cookbook_versions(ChefConfig.cookbook_versions_for_env)

