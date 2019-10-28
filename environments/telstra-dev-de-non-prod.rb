name "telstra-dev-de-non-prod"

description "The Telstra Development environment"

default_attributes(
# DISABLED AFTER MIGRATION COMPLETE
 'fixhostname' => true,
 'fixhostsfile' => true,
# 'fixhostname' => false,
# 'fixhostsfile' => false,
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
  "chef_client" => {
        "server_url" => "https://192.168.8.24", ##maybe to be removed
        "http_proxy" => "http://192.168.15.8:14239",
        "https_proxy" => "http://192.168.15.8:14239"
  },
  'iptables-stop' => false,
  "domainname" => "iotdev.telstra.com",
  'yum' => {
    "proxy" => "http://192.168.15.8:14239",
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
    "address" => "manage.iotdev.telstra.com"
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
  ## Added following 6 rows on 01102019
     "docker-version": "1.13.1-102.git7f2769b.el7.centos",
     "docker" => {
       "log" => {
         "on-file" => true
       }
     },
     "deployK8S4env" => "telstra-dev-de-non-prod",
     "attachedEnvs" => ["telstra-dev-de-non-prod"],
     "token" => "2aw8ga.krilwvobqpc4vgoz",
     "images-connString" => "https://K8Simages:K8S^imAgEs5000%@resources.cumulocity.com/kubernetes-images",
#     "images-version" => "9.16.3",
     "images-version" => "1004.0.6-1",
#     "images2install" => [ "cep" ]
     "images2install" => [ "" ]
  },
  "cumulocity-karaf" => {
    #"version" => "9.12.5-1",
    ## 29.11.2018
    #"version" => "9.16.3-1",
    ## 04.02.2019:
    #"version" => "9.16.6-1",
    ## 18.03.2019:
    #"version" => "9.20.7-1",
    ## 17.05.2019
    #"version" => "9.20.10-1",
    ## 04.06.2019
    #"version" => "1004.0.6-1",
    ## 14.08.2019
    "version" => "1004.6.8-1",

    #"ssa-version" => "9.16.3-1",
    #"ssa-version" => "1004.0.6-1",
    "ssa-version" => "1004.6.8-1",
    ##"memory_left_for_system" => "2048",
    ## 04.02.2019:
    "memory_left_for_system" => "6096",
    "management-access": [ "84.10.6.110", "192.168.8.0/22", "62.96.250.8/28", "52.58.107.37", "52.58.87.112", "52.63.24.152", "10.0.0.0/8", "10.60.71.217" ],
    "notification" => true,
    "oort-enabled" => true,
    "cep-server-enabled" => true,
    "CUMULOCITY_LICENCE_KEY" => "7f5ca894e267fbc2c236243829389da8129f5793a696ef256f0695993954095bdbca88c745a0e360ea75ff8208366bc1303e015c59f3a90a20764727bd0dc05a",
     "karaf" => {
        "memory"=> {
          "max_direct_memory" => "2048M"
                 },
        },
  },
  "cumulocity-core" => {
    "properties" => {
      "contextService.rdbmsURL" => "jdbc:postgresql://localhost",
      "contextService.rdbmsDriver" => "org.postgresql.Driver",
      "contextService.rdbmsUser" => "postgres",
#      "contextService.rdbmsPassword" => "",
#      "system.connectivity.microservice.url" => "http://192.168.17.34:8092/jwireless",
#      "smsGateway.host" => "http://telstra-el7-dev-agents:8688/sms-gateway",
#	04.02.2019
       "smsGateway.host" => "http://localhost:80/service/messaging",
       #"smsGateway.host" => "http://telstra-el7-dev-agents:8688/sms-gateway",
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
      "system.password.limit.validity": "180",
      "system.password.history.size": "10",
      "system.password.green.min-length": "12",

        "system.two-factor-authentication.enabled": true,
        "system.two-factor-authentication.enforced.group": "admins",
#        "system.two-factor-authentication.host": "http://sms-gateway-server-scope-management.telstra-dev-de-non-prod.svc.cluster.local/smsmessaging",
#        "system.two-factor-authentication.host": "http://sms-gateway-server-scope-management.telstra-dev-de-non-prod.svc.cluster.local",
# 05.12.2018
         "system.two-factor-authentication.host": "http://sms-gateway-scope-management.telstra-dev-de-non-prod.svc.cluster.local",
#        "system.two-factor-authentication.host": "http://telstra-el7-dev-agents:8688/sms-gateway",
# 04.02.2019 - doesn't work!
#       "system.two-factor-authentication.host": "http://localhost:80/service/messaging",
        "system.two-factor-authentication.senderAddress": "+61418368753",
        "system.two-factor-authentication.senderName": "Telstra IoT",
        "system.two-factor-authentication.provider": "telstra",
        "system.two-factor-authentication.telstra.baseUrl": "https://free.rcs.telstra.com/messaging/v1/sms/outbound/acr%3Acumulocity/requests",
        "system.two-factor-authentication.telstra.username": "cumulocity",
        "system.two-factor-authentication.telstra.password": "xBg5Wa8M",
        "system.two-factor-authentication.max.inactive": "15",

      ## "default.tenant.microservices" => "device-simulator, smartrule, feature-microservice-hosting, cep, feature-cep-custom-rules",
      ## feature-cep-custom-rules and cep removed by request of David 02052018 (lundsten)
      "default.tenant.microservices" => "device-simulator, smartrule, feature-microservice-hosting",
#      "migration.tomongo.default" => "POSTGRES_READ_WRITE",
      "migration.tomongo.default" => "MONGO_READ_WRITE",
      #"tenant.admin.grants.disabled" => true,
      "system.support-user.enabled" => true,
      "tenantSuspend.mail.sendtosuspended" => false,
      "tenantSuspend.mail.additional.address" => "IoT_Telstra_Support@telstra.com",
#      "device-simulator.microservice.url" => "http://${DEVICE-SIMULATOR-AGENT-SERVER}:6666",
#      "smartrule.microservice.url" => "http://${SMARTRULE-AGENT-SERVER-ESPER}:8334",
#      "smartrule.microservice.url" => "http://127.0.0.1:8334",
#      "smartrule.microservice.url" => "http://localhost:8334",
      "email.host" => "localhost",
      "email.from" => "no-reply@iotdev.telstra.com",
      "errorMessageRepresentationBuilder.includeDebug" => "false",
      "passwordReset.email.subject" => "Password reset",
      "passwordReset.token.email.template" => 'Dear Telstra user,\n\n\
            You or someone else entered this email address when trying to change the password of a Telstra portal user.\n\n\
            Please use the following link to reset your password: \n\
            {host}?token={token}&showTenant\n\n\
            If you were not expecting this email, please ignore it. \n\n\
            Kind regards,\n\
            Telstra support team\n',
      "passwordReset.user.not.found.email.template" => 'Hi there,\n\n\
            you or someone else entered this email address when trying to change the password of a Telstraportal user.\n\n\
            However, we could not find the email address in your account. Please contact the administrator of your \
            account to set your email address and password. If you are the administrator of the account,\
            please use the email address that you registered with.\n\n\
            If you were not expecting this email, please ignore it. In case of questions, please get in contact with the administrator of the Telstra Tesbed portal. \n\n\
            Kind regards,\n\
            The Telstra support team\n',
      "passwordReset.success.email.template" => 'Dear Telstra user,\n\n\
            Your password on {host} has been recently changed. \n\
            If you or your administrator made this change, you do not need to do anything more. \n\
            If you did not make this change, please contact your administrator.\n\n\
            Kind regards,\n\
            Your Telstra support team\n',
      "passwordReset.invite.template" => 'Hi there,\n\n\
            Please use the following link to reset your password: \n\
            {host}/apps/devicemanagement/index.html?token={token}\n\n\
            If you were not expecting this email, please ignore it. \n\n\
            Kind regards,\n\n\
            Your Telstra support team\n'
    }
  },
    "cumulocity-mongo" => {
#        'members-check' => false,
        "installEnterprise" => true, # migration change
        "wiredtiger-cache" => 3,
        "sharedkey-content" => "d+duGNkxtqehDM+97/cwPEXztjNMrApyZH6u5WBf1L6M9j2jLRVlk0Pt3u3KxAVA\nRdlOhX9fLzekQeb0ScElwPJS7IamP3kuFnbzeh9EKKcSYI555DkL1Wx3RRm7wjwW\nrAyphpH3v4MJ73240BP7KDqj87o+IijR68Z31y9JvP7m1l3G9vln0br1piEzlJg9\nLALZGOXC3V8iDvqPWDntt1dWvgQSxlu8QS9aE2qYcZDqy5E1PomRzX6KzHM/9ZXd\nOO3INgwxbZPBOrz0hjnv0EEHM7hW8TCGAjw9RL+FgI4E7fOGSco7pP7w2InYhWrW\n+6wNSVn+23CTQ+NyeIHD9ujhLKA2GBsh9PvmIGqL7krewLWQ0guuFXG1qkhghdw4\nWIfKjV0CgF5hp7nI/xX3HNRsaP4sXJoNqfURYrYOsY/mAOsSftjVJpXGqAz20l0U\nGePvsrVDw03UA/k79N0rt+z5SAf7Av0N2MWg71IoskqSr1gr2Knyzg/FsnkzKqTW\n1tRc+b5TRMIuHewvwROtgXeweAbjU7dgNnBJBOH6g3lec8pB8A0lMluY4sQ78Dby\n4xeEOCLuh9prCWaI1TFakeW/PQpmzbRm0z01tuZsyZwuZj7PYljQoNYXNhsj1nMA\n+J9Ebbkh0hlFcItMSCGfh6nB15vVTJOKO6RBkWTOxny1dJAyZxCMv7pfADsu9Yuo\nH75oJhhonnTwyWO+2lWQHPil/wC7QE79fMSpMsr61lL9CjNHXUU1Mpk9/BdNAvcI\nc/shD0eOoHWG4dRjZCk2PnlleCgM2ht0YCgH9qnZP3W0AKFg58ZTCfuMIB8f7ECe\n7todUW0Z5a4gCWcPqMdnkVpndnvUDR8/LOhVKXZC/e//2wwVanHKCxLwzs6SiN+0\n0IBqVtclXqMI8ZpuYtUKiYUFZz0sp52QZ3K8aCbY8fnkqXbl3JV4Um3w5aC/kQ6I\nuTMhRQbZ9b+GqasdKYwcGXHE7yz3",
        "mongodb.initUser" => "init-root",
         "version" => "3.6"
#        "mongodb.initPassword" => "edf933ds^5T"
  },
    "cumulocity-external-lb" => {
        "landing_page" => "https://iotdev.telstra.com/apps/devicemanagement",
        "paas_default_page" => "https://$http_host/apps/$defapp/",
        "paas_public_default_page" => "https://iotdev.telstra.com/apps/dmpublic",
        "usePostgresForPaaS" => false,
        "paas_redirection" => true,
        "proxy_cache" => true,
        "DNSResolver" => "192.168.8.2",
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
        "nginx" => {
            "NGinxPort" => "openresty",
             "version" => "1.11.2.4-20.el7.centos.c8y.8.11.1" # migration change
        }
  },
    'cumulocity-rsyslog' => {
      'log-sms-gateway' => true,
#      'cross-env-log-server' => 'cumulocity-multinode-prod',
      'log-server-ext-address' => '192.168.15.8',
      "encrypt_log_forwarding" => true
  },
    'cumulocity-ssagents' => {
      'useTags' => true
    },
   "cumulocity-cep" => {
       "properties" => {
         " esperha.storage" => "/mnt/esperha-storage/"
     },
  },
  'monitoring-agent' => {
    #'verbose' => true,
    #'includeCustomHosts' => "/usr/share/cumulocity-agent/lua/monitoring/hosts.custom.lua",
    #'includeCustomPlugins' => "/usr/share/cumulocity-agent/lua/monitoring/plugins.custom.lua",
    'createPlatformUser' => true,
    'autoRegistration' => {
      'enable' => true,
      'groupName' => 'Telstra NG Development'
    }
  },
    'backup_script' => {
      'http_proxy' => "http://192.168.15.8:14239",
      'AWS_SECRET_ACCESS_KEY' => "AR+xGrTIw/yY6Mzw0qMlwNjJ9AM5CQJ14hax3Sx6",
      'AWS_ACCESS_KEY_ID' => "AKIAI6X7RILJSAKCZBKA",
      'smtp_relay' => "smtp://localhost",
      'mail_from' => "support@cumulocity.com",
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
