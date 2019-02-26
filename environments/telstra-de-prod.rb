name "telstra-de-prod"

description "The Telstra Production environment"

default_attributes(
# DISABLED AFTER MIGRATION COMPLETE
# 'fixhostname' => true,
# 'fixhostsfile' => true,
 'fixhostname' => false,
 'fixhostsfile' => false,
# "cumulocity-external-lb" => {
#        "nginx" => {
#            "NGinxPort" => "openresty",
#            "version" => "1.11.2.4-20.el6.c8y.8.7.2"
#        }
#  },
 "elb" => {
      "name" => "production"
    }
)
override_attributes(
  'openssh' => {
    'server' => {
      'banner' => '/etc/ssh/sshd-banner',
      'client_alive_interval' => '360'
    }
  },
  "chef_client" => {
        "server_url" => "https://XXXXXXXXXXXXXXXXXX"
  },
  'iptables-stop' => false,
  "domainname" => "iot.telstra.com",
  'yum' => {
    "proxy" => "http://192.168.6.12:14239",
    'repositories' => {
        'cumulocity-testing' => {
            'enabled' => "0"
      },
    'cumulocity' => {
            'url' => "https://cumulocity:ACceP=m+2m@yum.cumulocity.com/centos/$releasever/cumulocity/x86_64/",
            'name' => "cumulocity",
            'description' => "Cumulocity Repository",
            'enabled' => "1",
            'sslverify' => "0"
            }
        }
  },
  "environment" => {
    "address" => "manage.iot.telstra.com"
  },
  "java" => {
     "jdk_version" => "8"
  },
  "nagios" => {
    "performance_monitoring" => true,
    "notifications_enabled" => 1,
    "notify_by_logger" => false,
    "notify_by_legacy_client" => true,
    "server" => {
        "version" => "3.4.3",
        "checksum" => "adb04a255a3bb1574840ebd4a0f2eb76"
        }
    },
  "cumulocity-kubernetes" => {
     "deployK8S4env" => "telstra-de-prod",
     "attachedEnvs" => ["telstra-de-prod"],
     "token" => "xtticj.9x15x34zdmuix42w",
     "images-connString" => "https://K8Simages:K8S^imAgEs5000%@resources.cumulocity.com/kubernetes-images",
     "images-version" => "9.16.6",
     "images2install" => [ "" ]
#     "images-version" => "8.19.19",
#     "images2install" => [ "cep", "cep-small" ]
  },
  "cumulocity-karaf" => {
    ##"version" => "8.19.17-1",
    ##"version" => "9.0.24-1",
    ##"version" => "9.8.9-1",
    ##"version" => "9.12.10-1",
    ##"version" => "9.12.11-1",
    "version" => "9.16.6-1",
    ##"ssa-version" => "8.19.5-1",
    ##"ssa-version" => "9.12.11-1",
    "ssa-version" => "9.16.6-1",
    ##"memory_left_for_system" => "2048",
    "memory_left_for_system" => "5120",
    "management-access": [ "84.10.6.110", "192.168.0.0/21", "62.96.250.8/28", "52.58.107.37", "52.58.87.112", "52.63.24.152", "10.0.0.0/8", "192.168.3.77" ],
    "notification" => true,
    "oort-enabled" => true,
    "cep-server-enabled" => true,
    "CUMULOCITY_LICENCE_KEY" => "956c00734da21de672ff6aa2e07e58e0c9c2406b8e3bb19f4a83b2a53833852a9dffc66e39ea3cbe3346d2ddee80073983996084fe1e692e6d2918d30140970d"
  },
  "cumulocity-core" => {
    "properties" => {
      "contextService.rdbmsURL" => "jdbc:postgresql://localhost",
      "contextService.rdbmsDriver" => "org.postgresql.Driver",
      "contextService.rdbmsUser" => "postgres",
#      "contextService.rdbmsPassword" => "",
#      "system.connectivity.microservice.url" => "http://192.168.17.34:8092/jwireless",
#      "smsGateway.host" => "http://192.168.17.34:8688/sms-gateway",
      "system.connectivity.microservice.url" => "http://192.168.3.69:8092/jwireless",
      "smsGateway.host" => "http://localhost:8688/sms-gateway",
      "mongodb.user" => "c8y-root",
#      "mongodb.password" => "",
      "mongodb.admindb" => "admin",
      "contextService.tenantManagementDB" => "management",
      "cumulocity.environment" => "PRODUCTION",
      "auth.checkBlockingFromOutside" => true,
#            "errorMessageRepresentationBuilder.includeDebug" => "false",
      "default.tenant.applications" => "administration,devicemanagement,cockpit",
#      "management.admin.password" => "",
#      "tenant.admin.password" => "",
#      "admin.password" => "",
#      "admin.password" => "",
      "system.password.enforce.strength": true,
      "system.password.limit.validity": "100",
      "system.password.history.size": "10",
      "system.password.green.min-length": "12",

        "system.two-factor-authentication.enabled": true,
        "system.two-factor-authentication.enforced.group": "admins",
        "system.two-factor-authentication.host": "http://127.0.0.1:8688/sms-gateway",
        "system.two-factor-authentication.senderAddress": "+61418368753",
        "system.two-factor-authentication.senderName": "Telstra IoT",
        "system.two-factor-authentication.provider": "telstra",
        "system.two-factor-authentication.telstra.baseUrl": "https://free.rcs.telstra.com/messaging/v1/sms/outbound/acr%3Acumulocity/requests",
        "system.two-factor-authentication.telstra.username": "cumulocity",
        "system.two-factor-authentication.telstra.password": "xBg5Wa8M",
        "system.two-factor-authentication.max.inactive": "15",

      "default.tenant.microservices" => "device-simulator, smartrule, feature-microservice-hosting",
      "migration.tomongo.default" => "MONGO_READ_WRITE",
      #"tenant.admin.grants.disabled" => true,
      "system.support-user.enabled" => true,
      "tenantSuspend.mail.sendtosuspended" => false,
      "tenantSuspend.mail.additional.address" => "IoT_Telstra_Support@telstra.com",
      "device-simulator.microservice.url" => "http://${DEVICE-SIMULATOR-AGENT-SERVER}:6666",
      #"smartrule.microservice.url" => "http://${SMARTRULE-AGENT-SERVER-ESPER}:8334",
#      "smartrule.microservice.url" => "http://127.0.0.1:8334",
#      "smartrule.microservice.url" => "http://192.168.3.69:8334",
      "smartrule.microservice.url" => "http://localhost:8334",
      "email.host" => "192.168.6.12",
      "email.from" => "no-reply@iot.telstra.com",
      "errorMessageRepresentationBuilder.includeDebug" => "false",
      "passwordReset.email.subject" => "Password reset",
      "passwordReset.token.email.template" => 'Dear Telstra Testbed user,\n\n\
            You or someone else entered this email address when trying to change the password of a Telstra Testbed portal user.\n\n\
            Please use the following link to reset your password: \n\
            {host}?token={token}&showTenant\n\n\
            If you were not expecting this email, please ignore it. \n\n\
            Kind regards,\n\
            Telstra Testbed support team\n',
      "passwordReset.user.not.found.email.template" => 'Hi there,\n\n\
            you or someone else entered this email address when trying to change the password of a Telstra Testbedportal user.\n\n\
            However, we could not find the email address in your account. Please contact the administrator of your \
            account to set your email address and password. If you are the administrator of the account,\
            please use the email address that you registered with.\n\n\
            If you were not expecting this email, please ignore it. In case of questions, please get in contact with the administrator of the Telstra Tesbed portal. \n\n\
            Kind regards,\n\
            The Telstra Testbed support team\n',
      "passwordReset.success.email.template" => 'Dear Telstra Testbed user,\n\n\
            Your password on {host} has been recently changed. \n\
            If you or your administrator made this change, you do not need to do anything more. \n\
            If you did not make this change, please contact your administrator.\n\n\
            Kind regards,\n\
            Your Telstra Testbed support team\n',
      "passwordReset.invite.template" => 'Hi there,\n\n\
            Please use the following link to reset your password: \n\
            {host}/apps/devicemanagement/index.html?token={token}\n\n\
            If you were not expecting this email, please ignore it. \n\n\
            Kind regards,\n\n\
            Your Telstra Testbed support team\n'
    }
  },
    "cumulocity-mongo" => {
        'version' => "3.6",
#        'members-check' => false,
        "installEnterprise" => true, # migration change
        ##"wiredtiger-cache" => 4,
        "wiredtiger-cache" => 2,
        "sharedkey-content" => "ZouoSxjiquk/ogK2oHyAAwEZbXaD+njUu15k0fS14u382CnX/0QbMMscUdWHi87V\ndBB3sXO3HYbEaQ+E1QAorySu6YGHJ7xfoB4z+90TlRLz/ohKx6+bLiNZkl7VKN8w\niILIdm/2T/phjEcpy8yp9XSfRPM+pDmjzs11UAEe7dTYG9U/8o+J+acAVzFaRWub\nfv0F7mC84hevY+JVHHBXKeyQKoJC/+oI+1JEtSi0Qyzq8MgfMVaod9J/BJ3ONcVR\nUNHstExxn/7sTJOuzH5EybcaluwkH93avuoELT23CM54IOd69Parwui0mARBQ2Vf\nFQoHL+FX2v66XgiTI2InJAIe/s9QxsqIGTNPVsYWs3aJpYAGTSlb1BcHEp6Msdu8\nURaxmMQGYiBhMseknvwkZE/xODXzbHsWus7++M1uX2AZTF+4aTuAnQ36xn0j20ED\nirWp2X16s1clBZu2XFIa7cpVfu+3PubTdHNLACIEMrcEjUOgOiQFIbWc8DVVKQfg\nIGthvrlZOge68do7ggrEGq+BXGWBN47HY4UkFWo6gO81Fo3UAZMsLauik4kMo7hV\n2ATSRlxyQq5dlYarq9fUKRRnHzz8VoCEmzkjrWu4TNY05+tIbhncPvNX9emws76N\nRwLRuLrWb1+TBnJQckkx98HiZCKy2vrVuXEiOilUpOtf6nWo6TEcFtx/9NvZXW8L\nTuRq3j8di2qYJcGm0BXdD7eK/oXrdCavBl3M9JrQXjDQhIhBMYCFn95Z9l0wu9Cg\nvE3MlXKXb9ic4PibQPHPYXGGFl32tpc6lULrijpxnWsOhsKb2NKAvpIKBnK3gflC\n8O/7rIyanYkvRr3Y2iw6G0P0ayjrSmb7tBG401Tkh8QqwfB9p/zLz7RajhaR2YLT\n6iektyN7chchFVHHYDIkX15TPa4A9jjqHhf1FWogt+xiAzPLjeggQRKSKR6h7qu3\nt10CxgaI5M102KhoYIR2AlXSTkqC",
        "mongodb.initUser" => "init-root",
        "mongodb.initPassword" => "edf933ds^5T"
  },
    "cumulocity-external-lb" => {
        "landing_page" => "https://iot.telstra.com/apps/devicemanagement",
        "paas_default_page" => "https://$http_host/apps/$defapp/",
        "paas_public_default_page" => "https://iot.telstra.com/apps/dmpublic",
        "usePostgresForPaaS" => false,
        "paas_redirection" => true,
        "proxy_cache" => true,
        "DNSResolver" => "192.168.0.2",
        "useIPAddress" => true,
        "useMQTTsupport" => true,
        "useSSL" => false,
        "force_proto_for_link_processor" => "https",
        "certificate_domain" => "cumulocity.com",
        "temp_chunkin" => false,
        "useKarafWebsocket" => true,
	"useLUAforSSLcerts" => nil,
	"useLUAforLimits" => true,
	"useLUAforHealthCheck" => true,
	"useMasterForPushOperations" => true,
        "nginx" => {
            "NGinxPort" => "openresty",
             "version" => "1.11.2.4-20.el7.centos.c8y.8.11.1" # migration change
        }
  },
    'cumulocity-rsyslog' => {
      'log-sms-gateway' => true,
      'cross-env-log-server' => 'cumulocity-multinode-prod',
      'log-server-ext-address' => '192.168.0.27'
  },
    'cumulocity-ssagents' => {
      'useTags' => true
    },
   "cumulocity-cep" => {
       "properties" => {
         " esperha.storage" => "/mnt/esperha-storage/"
     },
  },
  "syslog-ng" => {
    "forward" => true,
    "dsts" => {
      "generic" => {
         1 => {
           "ip" => "logging.cumulocity.com",
           "port" => "5140",
           "transport" => "udp"
         }
     },
      "http" => {
         1 => {
           "ip" => "192.168.0.94",
           "port" => "514",
           "transport" => "tcp"
         }
       }
     }
  },
    'backup_script' => {
      'http_proxy' => "http://192.168.6.12:14239",
      'AWS_SECRET_ACCESS_KEY' => "AR+xGrTIw/yY6Mzw0qMlwNjJ9AM5CQJ14hax3Sx6",
      'AWS_ACCESS_KEY_ID' => "AKIAI6X7RILJSAKCZBKA",
      'smtp_relay' => "smtp://192.168.6.12",
      'mail_from' => "backup_alerts@iot.telstra.com",
      'rcpt_to' => "alerts@cumulocity.com"
  }
#  'monit' => {
#    'mongo' => {
#      'checkAltPort' => false
#     },
#      'cep' => {
#        'reaction' => 'alert'
#     },
#      'karaf' => {
#        'reaction' => 'alert'
#     }
#  }

)

#cookbook_versions(ChefConfig.cookbook_versions_for_env)
