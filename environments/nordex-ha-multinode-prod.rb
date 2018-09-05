name "nordex-ha-prod"

description "The 8.19 Nordex HA production environment"

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
        "server_url" => "https://nxchefstg01v.mgmt.qa.nif.nordex.nexinto.com"
  },
  "domainname" => "nifqa.nordex-online.com",
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
    "address" => "nifqa.nordex-online.com"
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
     "deployK8S4env" => "nordex-ha-prod",
     "attachedEnvs" => ["nordex-ha-prod"],
     "token" => "o9rwwd.gfczmyzi9up72w2h",
     "images-connString" => "https://K8Simages:K8S^imAgEs5000%@resources.cumulocity.com/kubernetes-images",
     ##"images-version" => "8.19.15",
     "images-version" => "9.0.16",
     "images2install" => [ "cep" ],
     "heapster" => {
       "enabled" => true
     }
  },
  "cumulocity-karaf" => {
    ##"version" => "8.19.15-1",
    ##"version" => "8.19.26-1",
    "version" => "9.0.16-1",
    "memory_left_for_system" => "4096",
    "notification" => true,
    "oort-enabled" => true,
    "cep-server-enabled" => true,
    ##"ssa-version" => "8.19.4-1",
    "ssa-version" => "9.0.14-1",
#    "CUMULOCITY_LICENCE_KEY" => "57ff536fc57de16887ed896922254ead2ffaa07db1c4a037dee0f537cc237da283a369ae7b78ffb890779b8710e43dcfe7bb329bd627e3e5d2371c3d597ae2c8"
    "CUMULOCITY_LICENCE_KEY" => "7737924a1131eadf558cdbd634ebec89ff80febc86d6972d31e243c86d7dde119451712f9a915f3b998451a622068a9dcaf8c1faa29755ec4ffad9d5e961e102"
  },
  "cumulocity-core" => {
    "properties" => {
      "contextService.rdbmsURL" => "jdbc:postgresql://localhost",
      "contextService.rdbmsDriver" => "org.postgresql.Driver",
      "contextService.rdbmsUser" => "postgres",
#      "system.connectivity.microservice.url" => "http://192.168.17.34:8092/jwireless",
#      "smsGateway.host" => "http://192.168.17.34:8688/sms-gateway",
      "mongodb.user" => "c8y-root",
      "mongodb.admindb" => "admin",
      "contextService.tenantManagementDB" => "management",
      "cumulocity.environment" => "PRODUCTION",
      "auth.checkBlockingFromOutside" => false,
#     "errorMessageRepresentationBuilder.includeDebug" => "false",
      ## NORD:18:ex
      "default.tenant.applications" => "administration,devicemanagement,cockpit,feature-cep-custom-rules",
      "management.admin.password" => "516750cf15f1d6e8e15d3ba7dfabe4549bf2a8c4b3f563a0b73c97457c105459",
      "tenant.admin.password" => "516750cf15f1d6e8e15d3ba7dfabe4549bf2a8c4b3f563a0b73c97457c105459",
      "admin.password" => "516750cf15f1d6e8e15d3ba7dfabe4549bf2a8c4b3f563a0b73c97457c105459",
      "cometd.heartbeat.minutes" => "4",
      "default.tenant.microservices" => "device-simulator, smartrule, cep",
      "system.support-user.enabled" => true,
      "tenantSuspend.mail.sendtosuspended" => false,
      "tenantSuspend.mail.additional.address" => "operations@cumulocity.com",
      "device-simulator.microservice.url" => "http://${DEVICE-SIMULATOR-AGENT-SERVER}:6666",
      "smartrule.microservice.url" => "http://127.0.0.1:8334",
      "microservice.websocket.port" => 8303,
      # Use mongoDB only:
      ##"migration.tomongo.default" => "POSTGRES_READ_WRITE",
      "migration.tomongo.default" => "MONGO_READ_WRITE",
      "email.from" => "no-reply@nifqa.nordex-online.com",
      "errorMessageRepresentationBuilder.includeDebug" => "false",
      "passwordReset.email.subject" => "Password reset",
      "passwordReset.token.email.template" => 'Dear Testbed user,\n\n\
            You or someone else entered this email address when trying to change the password of a Testbed portal user.\n\n\
            Please use the following link to reset your password: \n\
            {host}?token={token}&showTenant\n\n\
            If you were not expecting this email, please ignore it. \n\n\
            Kind regards,\n\
            Testbed support team\n',
      "passwordReset.user.not.found.email.template" => 'Hi there,\n\n\
            you or someone else entered this email address when trying to change the password of a Testbedportal user.\n\n\
            However, we could not find the email address in your account. Please contact the administrator of your \
            account to set your email address and password. If you are the administrator of the account,\
            please use the email address that you registered with.\n\n\
            If you were not expecting this email, please ignore it. In case of questions, please get in contact with the administrator of the Tesbed portal. \n\n\
            Kind regards,\n\
            The Testbed support team\n',
      "passwordReset.success.email.template" => 'Dear Testbed user,\n\n\
            Your password on {host} has been recently changed. \n\
            If you or your administrator made this change, you do not need to do anything more. \n\
            If you did not make this change, please contact your administrator.\n\n\
            Kind regards,\n\
            Your Testbed support team\n',
      "passwordReset.invite.template" => 'Hi there,\n\n\
            Please use the following link to reset your password: \n\
            {host}/apps/devicemanagement/index.html?token={token}\n\n\
            If you were not expecting this email, please ignore it. \n\n\
            Kind regards,\n\n\
            Your Testbed support team\n'
    }
  },
    "cumulocity-mongo" => {
#       'members-check' => false, # default: true
#       "installEnterprise" => true, # migration change
        "wiredtiger-cache" => 2,
        "sharedkey-content" => "SfiChyQkt9uGBRFOgKxj0o8rLZu+YXHaH6vfvDUHTotLM9/M3CaL275QjvC95nY6\nMM9zmkTaNGJa7jzxDydJ5FaN48EHDQxUIDg38w9UJEipmkWoNNyshKwXFmGvwdFe\n3iy3VqQ/LVCjBN8zuwHSA1OpmhzTOR5QRl6e9hMs1PMRmdZikcyR2mkVYgX3rNRf\nc3KsocU7EFCqX1Ry8P3vMw6gg987AdfEeadb/GueLq9uc5BEAdYX4vO40AuHUVO9\nFYAjVEH/v7rQ4WV15hRjyspYhOATu4EBg0B3adovK4AHgNvxFSjYbfeXXJjMLNSq\n1V2aFnGoTSdJ6PAypJXoz1FErUCRit/YIhKqLun2kN41iDC31+vhVHGLrmXIUqRP\n8eehzguuHmPsBJ1FWN1BCzGV3DGlTvKF8fVHw7s/jIugrx3kk+SkInqICI63Y/DP\nhSbO38a3ZuKc3Slk2vyoKyKvcc9rYQ7LcGEL2WbYdDy/qj+oMmBZ5ATKQGlQci9i\nlc7VUW9U9tFvAUhy/4V/Tp1GO6ZGvo3hna4U6Kielu4UMy7NpHOCPHQuM9wKS2Rp\nf6lHQL84HYBW4oPAqiCfSCNZRe+7L8IMA4pi/Retutf1JTxv+vpci06NQiXAWIDA\nwrvcBoeAMFUriLJaAOvPwdKN1OsQx+E/9QsUw8I42IU1oyF4/7QbyFj/Fv3kd1Wa\nYRBJPyPGKXVxzer1iq5wDzbmVFWjL+mdss8ObpCTI5pIf9skAA5++TC/quE0qSZ7\n7BN9ctO3L1xXQOnXb7QtyT3xUMgygVAfd3NaaL42A1EkIEev/BHNQfAekJCT1hZL\nOICIELX5vkXun5BcBYPzyDP3uaS3/maxnZyaOQmLcJsGFCX8DWOWnt1amgZTCiig\nW+ghKjqtaQVuZwYkNq/9KfloHNO0l5fxrXYhYgbN2Jti1pxoVcQRU9xMfk+TfaJA\nKpve2PdTmivynPqtTO6oL6fUwvpT",
        "mongodb.initUser" => "init-root",
        "mongodb.initPassword" => "test#1302"
  },
    "cumulocity-external-lb" => {
        "landing_page" => "https://nifqa.nordex-online.com/apps/devicemanagement",
        "paas_default_page" => "https://$http_host/apps/$defapp/",
        "paas_public_default_page" => "https://nifqa.nordex-online.com/apps/dmpublic",
        "usePostgresForPaaS" => false,
        "paas_redirection" => true,
        "proxy_cache" => true,
        "useIPAddress" => true,
        "useMQTTsupport" => true,
        "useKarafWebsocket" => true,
        "useSSL" => true,
        "certificate_domain" => "nifqa.nordex-ag.com",
        "temp_chunkin" => false,
	"useLUAforSSLcerts" => nil,
	"useLUAforLimits" => true,
        "nginx" => {
            "NGinxPort" => "openresty",
             "version" => "1.11.2.4-20.el7.centos.c8y.8.11.1" # migration change
        }
  },
#    'cumulocity-rsyslog' => {
#      'cross-env-log-server' => "cumulocity-multinode-prod",
#      'log-server-ext-address' => "monitoring.cumulocity.com"
#  },
   "cumulocity-cep" => {
       "properties" => {
         " esperha.storage" => "/mnt/esperha-storage/"
     },
  },

   "cumulocity-ssagents" => {
	"scriptDir" => "/root",
	"useTags" => true,
	"ssAgentsIP" => "172.31.27.65",
	  },

   "cumulocity-rsyslog" => {
        "log-server-ext-address" => "10.90.174.12",
        "forward-to-graylog" => true
         },

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
