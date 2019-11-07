name "nordex-prod"

description "The Nordex PROD environment"

default_attributes(
# DISABLED AFTER MIGRATION COMPLETE
# 'fixhostname' => true,
# 'fixhostsfile' => true,
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
        "server_url" => "https://nxchefprd01v.mgmt.prd.nif.nordex.nexinto.com"
  },
  "domainname" => "nifprd.nordex-online.com",
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
    "address" => "nifprd.nordex-online.com"
  },
  "java" => {
     "jdk_version" => "8"
  },
  "nagios" => {
    "server" => {
       "users" => {
          "admin_role" => "nagios_admin",
    },
        "version" => "3.4.3",
        "checksum" => "adb04a255a3bb1574840ebd4a0f2eb76"
        }
    },
  "cumulocity-kubernetes" => {
     "docker-version": "1.13.1-102",
     "deployK8S4env" => "nordex-prod",
     "attachedEnvs" => ["nordex-prod"],
     "token" => "r5oeyz.bbjrvslqebogcekd",
     "images-connString" => "https://K8Simages:K8S^imAgEs5000%@resources.cumulocity.com/kubernetes-images",
    "docker-registry-image" => "cumulocity/registry:2.6.1",
     #"images-version" => "9.16.2",
     "images-version" => "1004.6.12",
     "images2install" => [ "",""],
     "endpoints" => {
       "cumulocity" => [ "10.90.199.97" ]
     },
     "docker" => {
       "log" => {
         "on-file" => true
       }
     }
  },
  "cumulocity-karaf" => {
    #"version" => "9.16.2-1",
    #"version" => "1004.6.12-1",
    "version" => "1005.0.3-1",
#    "memory_left_for_system" => "16384",
    "memory_left_for_system" => "18432",
    "notification" => true,
    "oort-enabled" => true,
    "management-access" => [ "10.90.199.224/27" ],
    "cep-server-enabled" => true,
    "openrelayIP" => "10.1.12.31",
    "openrelayPORT" => "25",
    "CUMULOCITY_LICENCE_KEY" => "8bf8becd1d02049fd013091fc0270107482af4531e525e1781f356113c96e5a9a45c857a31c1b4a201b759394264b33fd3e17973ebedf19763b19b5022a38f12",
    "karaf" => {
      "memory" => {
        # Note: M for MB is required
        "max_direct_memory" => "2560M",
        }
      }
  },
  "cumulocity-core" => {
    "properties" => {
      "contextService.rdbmsURL" => "jdbc:postgresql://localhost",
      "contextService.rdbmsDriver" => "org.postgresql.Driver",
      "contextService.rdbmsUser" => "postgres",
      "mongodb.user" => "c8y-root",
      "mongodb.admindb" => "admin",
      "value-fragments-finder.algorithm" => "traversing",
      "contextService.tenantManagementDB" => "management",
      "cumulocity.environment" => "PRODUCTION",
      "auth.checkBlockingFromOutside" => false,
#            "errorMessageRepresentationBuilder.includeDebug" => "false",
      "default.tenant.applications" => "administration,devicemanagement,cockpit,feature-microservice-hosting",
      "management.admin.password" => "168c051782985e610e5baceb3c640a8b664decb393d4f9bce78ca1e1bf53f608", # eoTu6ge1UWou0ca
      "tenant.admin.password" => "168c051782985e610e5baceb3c640a8b664decb393d4f9bce78ca1e1bf53f608", # eoTu6ge1UWou0ca
      "admin.password" => "168c051782985e610e5baceb3c640a8b664decb393d4f9bce78ca1e1bf53f608", # eoTu6ge1UWou0ca
      "smsGateway.host" => "http://localhost:8181/service/messaging",
      "system.two-factor-authentication.enabled" => true,
      "system.two-factor-authentication.enforced.group" => "TFA",
#      "system.two-factor-authentication.host" => "http://${SMS-GATEWAY-SERVER}:8688/sms-gateway",
      "system.two-factor-authentication.host" => "http://localhost:8181/service/messaging",
      "system.two-factor-authentication.senderAddress" => "NordexPROD",
      "system.two-factor-authentication.senderName" => "NordexPROD",
      "system.two-factor-authentication.logout-on-browser-termination" => true,
      "system.two-factor-authentication.max.inactive" => "14",

      "system.two-factor-authentication.provider" => "openit",
      "system.two-factor-authentication.openit.baseUrl" => "https://sms.openit.de/put.php",
      "system.two-factor-authentication.openit.username" => "nordex_IoT-Platform",
      "system.two-factor-authentication.openit.password" => "X2uS.Mo32Bkq",
      "default.tenant.microservices" => "device-simulator,smartrule",
      "migration.tomongo.default" => "MONGO_READ_WRITE",
      #"tenant.admin.grants.disabled" => true,
      "system.support-user.enabled" => true,
      "tenantSuspend.mail.sendtosuspended" => false,
      "microservice.websocket.port" => 8303,
      "cometd.heartbeat.minutes" => "4",
      #"tenantSuspend.mail.additional.address" => "operations@cumulocity.com",
#      "device-simulator.microservice.url" => "http://${DEVICE-SIMULATOR-AGENT-SERVER}:6666",
#      "smartrule.microservice.url" => "http://127.0.0.1:8334",
      "email.from" => "no-reply@nifprd.nordex-online.com",
      "errorMessageRepresentationBuilder.includeDebug" => "false",
      "passwordReset.email.subject" => "Password reset",
      "passwordReset.token.email.template" => 'Dear Nordex user,\n\n\
            You or someone else entered this email address when trying to change the password of a Nordex portal user.\n\n\
            Please use the following link to reset your password: \n\
            {host}?token={token}&showTenant\n\n\
            If you were not expecting this email, please ignore it. \n\n\
            Kind regards,\n\
            Nordex support team\n',
      "passwordReset.user.not.found.email.template" => 'Hi there,\n\n\
            you or someone else entered this email address when trying to change the password of a Nordex portal user.\n\n\
            However, we could not find the email address in your account. Please contact the administrator of your \
            account to set your email address and password. If you are the administrator of the account,\
            please use the email address that you registered with.\n\n\
            If you were not expecting this email, please ignore it. In case of questions, please get in contact with the administrator of the Nordex Tesbed portal. \n\n\
            Kind regards,\n\
            The Nordex support team\n',
      "passwordReset.success.email.template" => 'Dear Nordex user,\n\n\
            Your password on {host} has been recently changed. \n\
            If you or your administrator made this change, you do not need to do anything more. \n\
            If you did not make this change, please contact your administrator.\n\n\
            Kind regards,\n\
            Your Nordex support team\n',
      "passwordReset.invite.template" => 'Hi there,\n\n\
            Please use the following link to reset your password: \n\
            {host}/apps/devicemanagement/index.html?token={token}\n\n\
            If you were not expecting this email, please ignore it. \n\n\
            Kind regards,\n\n\
            Your Nordex support team\n'
    }
  },
    "cumulocity-mongo" => {
#        'members-check' => false,
        "installEnterprise" => true, # migration change
        "initRunUser" => "mongod",
        "initRunGroup" => "mongod",
        "wiredtiger-cache" => 16,
        "sharedkey-content" => "9NqE1tTx8YAOm5QaqoAWQ8XcDDOmwdb1vtOAtjp8Wz9NnXjJt3HGAA1+2rBV6uId\n0aN7olp1895y1aokVXvQlDGAKyI9y6Wz9+LKpSgQq2lrLprKXk8Baq6K4PibxA6h\nHvBiVAhfiEiGQ9Hm8VAbnrV/jrdgXVuffwUGO0ZPBdvAw4gf0aWJsZKUTMW+ktmV\noH/XW9Xq2VW1Ut/YNamBWjjUTFmWv8W19uQ5W8mbro9DDCQ9DQFZ+9dgHXXEnUGY\nY1wBUcNgUuktgDdeF62P1mxob4JoyMoPWtLIxk7UpRH/m6Ff2/7f5/JHzCr9L3wP\n8PfUY0+siqIyvAW4XG9LuR4NiUzYDhUWM0yVGi7Lfa+I8O1sFTigHvVvBRXBxfk5\nO+768QKB/pteL2GSJ8ArhXvSL6VpsSEeWId9HxoQBg2rt5qbM3dEBj5rYr2FsDEq\nZTz4KDPXGO4BOk4r5EM5NNmpITMTYUCk9UGn7xODoEGIXiapGicp9ajwwTpNtUMp\n0mOqo314dBDWlvF8+NBA4IFL6q7kqGs0VCMxIguljyDI10RCrX7JR1x5yOTwiGLI\nUgECR+cpOWc1LIEvkHgeefR5agQP3JBhBS7BGy3rEoOXHe4FkkDR4VKJWPQiaC5c\nS2nMl3ahV9qwyGuHARVs5KT3rEk4f3Sr68ihJTorYSvVwkJyzUol/DxfcoasMyEs\n4JsPsNB0HxUbHkWr71vj4xqsvrJmI7c3li1YWKIpbEAcVCfRvsteTVR0DCfA9FRp\n+Vk/d8qzTbkKe47kliZOL0xY+Qujw6PTQyuUTPl6w5mj/ndjs+JecW/MBhc13WY4\n4yaotVKeTtJvI80xIzgWXhAZffvAW8Q3zFxVcF9ZzbP8V7YAQixJnrkkRO1DzpZt\nGfQrjJuoKC97WsilosLNeTmjkhgucRhfJW41+8nPNgYMFcNl573EJ5k6NGgCaqo4\n1/gD2vhLgQhgyqCmmw0E2uOU7/jO",
        "mongodb.initUser" => "init-root",
         "version" => "3.6"
  },
    "cumulocity-external-lb" => {
        "landing_page" => "https://nifprd.nordex-online.com/apps/devicemanagement",
        "paas_default_page" => "https://$http_host/apps/$defapp/",
        "paas_public_default_page" => "https://nifprd.nordex-online.com/apps/dmpublic",
        "usePostgresForPaaS" => false,
        "paas_redirection" => true,
        "proxy_cache" => true,
        "useIPAddress" => true,
        "useMQTTsupport" => true,
        "useSSL" => true,
        "force_proto_for_link_processor" => "https",
        "certificate_domain" => "nifprd.nordex-online.com",
#	"certificate_domain" => "acme.com",
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
#      'cross-env-log-server' => "cumulocity-multinode-prod",
#      'log-server-ext-address' => "monitoring.cumulocity.com"
  },

"cumulocity-filebeat" => {
# can be empty, all of them aree standard parameters
#
        "ssl-output" => true,
        "log-collectors" => "logging.monitor.c8y.io:6155",
        "output-to-file" => false,
        "output-file-path" => "/var/log/filebeat/json",
        "tag-rename" => nil,
        "env-prefix-rename" => false,
        "env-name-swap" => true,
},



  'ntp' => {
    'servers'      => ['195.180.1.1', '195.180.1.127', '10.134.190.14','10.134.190.15', '127.127.1.0', '194.233.128.238', '194.64.233.7' ],
  },


   "cumulocity-cep" => {
       "properties" => {
         " esperha.storage" => "/mnt/esperha-storage/"
     },
  },


  'monitoring-agent' => {
    'createPlatformUser' => true,
    'platformUsergroup' => "admins",
    'autoRegistration' => {
    'server_url' => "http://monitor.c8y.io", # url of monitoring instance
    'enable' => true,                # set it on true to enable the autoregistration feature
    'tenant' => 'environments',  # device/host will be registered on this tenant
    'username' => 'autoregister', # user with inventory/device control permissions (if you change this to <anotheruser>, you must change the KEY name "autoregister" under "autoRegistration" into "<anotheruser>" in the "extra" vault described below)
    'groupName' => 'Nordex PROD'     # this is the device group in the monitoring instance that will contain the registered devices
  },
    'monitor-cep' => false,
     # have to be set to true, if APAMA have to be checked
     # 'monitor-apama' => false
     'monitor-apama' => true,
        "apama-tenant" => {
        'management' => 'apama-small',
        'nordex' => 'apama-large'
        }

  },


  'cumulocity-opsmanager' => {
    'mmsGroupId' => '5c53ea45b324c77c8d24b13a',
    'mmsApiKey' => '5c53ea6fb324c77c8d24b1cce80622ca1f58493d12e1362e8844e001',
    'mmsBaseUrl' => 'http://nxopsprd01v.db.prd.nif.nordex.nexinto.com:80',
  }

)

#cookbook_versions(ChefConfig.cookbook_versions_for_env)

cookbook_versions({
'cumulocity-filebeat'=>'= 1004.6.5',
'cumulocity'=>'= 1004.6.5',
'cumulocity-backup-script'=>'= 1004.6.5',
'cumulocity-chaos-monkey'=>'= 1004.6.5',
'cumulocity-kubernetes'=>'= 1004.6.5',
'cumulocity-monitoring-agent'=>'= 1004.6.5',
'cumulocity-opsmanager'=>'= 1004.6.5',
'cumulocity-rsyslog'=>'= 1004.6.5',
'cumulocity-ssagents'=>'= 1004.6.5',
})

