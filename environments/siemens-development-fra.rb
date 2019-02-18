name "siemens-pre-prod"

description "The Siemens production environment"

default_attributes(
# DISABLED AFTER MIGRATION COMPLETE
 'fixhostname' => true,
 'fixhostsfile' => true,
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
#  "chef_client" => {
#        "server_url" => "https://<url_or_ip_chef_server>"
#  },
  "domainname" => "mciotextension.eu1-int.mindsphere.io",
  'yum' => {
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
    "address" => "mciotextension.eu1-int.mindsphere.io"
  },
  "java" => {
     "jdk_version" => "8"
  },
  "nagios" => {
    "server" => {
        "version" => "3.4.3",
        "checksum" => "adb04a255a3bb1574840ebd4a0f2eb76"
        }
    },
  "cumulocity-kubernetes" => {
     "deployK8S4env" => "siemens-pre-prod",
     "attachedEnvs" => ["siemens-pre-prod"],
     "token" => "8i37gl.uz4hyr4jpwic2d4n",
     "images-connString" => "https://K8Simages:K8S^imAgEs5000%@resources.cumulocity.com/kubernetes-images",
     "images-version" => "9.0.13",
     "images2install" => [ "" ]
  },
  "cumulocity-karaf" => {
    "version" => "9.12.5-1",
    "ssa-version" => "9.12.5-1",
    "memory_left_for_system" => "2048",
    "notification" => true,
    "oort-enabled" => true,
    "cep-server-enabled" => true,
    "CUMULOCITY_LICENCE_KEY" => "16ccda636bb309b74b5ddf4462ae110c1620f98cce085fecc755a7fdb98b1e9da7fcabbcc5a6e07a3daf7a1858471210c65085f7bf0649d02c8f845544bb300a"
  },
  "cumulocity-core" => {
    "properties" => {
      "contextService.rdbmsURL" => "jdbc:postgresql://localhost",
      "contextService.rdbmsDriver" => "org.postgresql.Driver",
      "contextService.rdbmsUser" => "postgres",
      "mongodb.user" => "c8y-root",
      "mongodb.admindb" => "admin",
      "contextService.tenantManagementDB" => "management",
      "cumulocity.environment" => "PRODUCTION",
      "auth.checkBlockingFromOutside" => false,
#            "errorMessageRepresentationBuilder.includeDebug" => "false",
      "default.tenant.applications" => "administration,devicemanagement,cockpit",
      "management.admin.password" => "", # insert password
      "tenant.admin.password" => "", # insert password
      "admin.password" => "", # insert password
      "system.files.max.size" => "524288000",
      #"system.two-factor-authentication.enabled" => false,
      #"system.two-factor-authentication.enforced.group" => "admins",
      #"system.two-factor-authentication.host" => "http://${SMS-GATEWAY-SERVER}:8688/sms-gateway",
      #"system.two-factor-authentication.senderAddress" => "",
      #"system.two-factor-authentication.senderName" => "Siemens",
      #"system.two-factor-authentication.logout-on-browser-termination" => true,
      #"system.two-factor-authentication.max.inactive" => "14",
      #"system.two-factor-authentication.provider" => "siemens",
      #"system.two-factor-authentication.siemens.baseUrl" => "https://m1free.rcs.msg.siemens.com/messaging/v1/sms/outbound/acr%3Acumulocity/requests",
      #"system.two-factor-authentication.siemens.baseUrl" => "https://free.rcs.siemens.com/messaging/v1/sms/outbound/acr%3Acumulocity/requests",
      #"system.two-factor-authentication.siemens.username" => "cumulocity",
      #"system.two-factor-authentication.siemens.password" => "xBg5Wa8M",
      ##"default.tenant.microservices" => "device-simulator, smartrule, cep",
      "default.tenant.microservices" => "device-simulator, smartrule, cep, feature-cep-custom-rules, sigfox-agent",
#      "migration.tomongo.default" => "POSTGRES_READ_WRITE",
      "migration.tomongo.default" => "MONGO_READ_WRITE",
      #"tenant.admin.grants.disabled" => true,
      "system.support-user.enabled" => true,
      "tenantSuspend.mail.sendtosuspended" => false,
      #"tenantSuspend.mail.additional.address" => "operations@cumulocity.com",
      "device-simulator.microservice.url" => "http://${DEVICE-SIMULATOR-AGENT-SERVER}:6666",
      "smartrule.microservice.url" => "http://127.0.0.1:8334",
      "email.from" => "no-reply@mciotextension.eu1-int.mindsphere.io",
      "errorMessageRepresentationBuilder.includeDebug" => "false",
      "passwordReset.email.subject" => "Password reset",
      "system.plugin.eventprocessing.enabled" => false,
      "system.plugin.eventprocessing.forwarding.enabled" => false,
      "system.plugin.eventprocessing.appmodule.enabled" => false,
      "passwordReset.token.email.template" => 'Dear Siemens user,\n\n\
            You or someone else entered this email address when trying to change the password of a Siemens portal user.\n\n\
            Please use the following link to reset your password: \n\
            {host}?token={token}&showTenant\n\n\
            If you were not expecting this email, please ignore it. \n\n\
            Kind regards,\n\
            Siemens support team\n',
      "passwordReset.user.not.found.email.template" => 'Hi there,\n\n\
            you or someone else entered this email address when trying to change the password of a Siemensportal user.\n\n\
            However, we could not find the email address in your account. Please contact the administrator of your \
            account to set your email address and password. If you are the administrator of the account,\
            please use the email address that you registered with.\n\n\
            If you were not expecting this email, please ignore it. In case of questions, please get in contact with the administrator of the Siemens Tesbed portal. \n\n\
            Kind regards,\n\
            The Siemens support team\n',
      "passwordReset.success.email.template" => 'Dear Siemens user,\n\n\
            Your password on {host} has been recently changed. \n\
            If you or your administrator made this change, you do not need to do anything more. \n\
            If you did not make this change, please contact your administrator.\n\n\
            Kind regards,\n\
            Your Siemens support team\n',
      "passwordReset.invite.template" => 'Hi there,\n\n\
            Please use the following link to reset your password: \n\
            {host}/apps/devicemanagement/index.html?token={token}\n\n\
            If you were not expecting this email, please ignore it. \n\n\
            Kind regards,\n\n\
            Your Siemens support team\n'
    }
  },
    "cumulocity-mongo" => {
#        'members-check' => false,
        #"installEnterprise" => true, # migration change
        "wiredtiger-cache" => 2,
        "sharedkey-content" => "XSF8n3qBBbyUZYUWuuShHra9pj8aF2tMXZ/pApCGwtf6o+nl8uJ4RcbR9jzhQcom\nmWxQ8yWy4Q5rbZF6KY+4inJXQ9Z0dRWYJ6TqTRhOF9v9OjySiSVKvQ192KIlggQ4\n/lLkiYt769/aRvPkqE5KgreFxHtxW5AufUBwoCENDSr2gu7O/wLLAahXwg+ZkCeZ\nEZ66XkU6sbuTe1BMLF3jP5FIYfqTkUnfllwYXnnyWfYWChVPF/Uu+nEg3frsb77f\nYrkRZ0pPUEU1m179c6MGLYW7VC4ObrkYHFCQcqfcEJhs+jhp8f/aA1wURe0QbxDA\nOrUkccN7enfv8h8bIfYzH9zFIba3ezvzPefez4R8WngMDh9gIWL2QYpT6cw0r9xb\nZ2mI6T2cvqbw1vXrZCzCfY7HIVE6Ui77dGBsC5E+lK8HTtP5ZxjenF45VPz8ANXD\nKVVmgCTio7muYAma+x9JHcc4SVkWOel60OhwoTum+i1lAB4a8z3kbMrqoKbjZbYb\n3hLoBYZDbj0mg77SNvge2Eiw56oHQW6Hl93H79bQsZi/mGFfRVpQwoeZAe6jJStn\n7eUnVvlB8BrTa85rafOuyZqSbSfL/NMtQiiDdvtBpxl7ySQVeT0XkSc2NJE6j4RZ\nVl/xVJKqpsZJEcxXO9TfIue6fbEjt+GzAMCoLcfetIbnBRnpGdpRjnnCndgz2v+6\nzDXaFvO6ZEV8L6HwwgZGT08FNs4dubW1Tb+RffIRYrok/uqBsQHATmi6ddRdVHNd\nLTL/TJ6Evp2k1+2KmP5AOA7vgtoHNBSEJF3HW68WidTli4GyHCRT1zjld+EL2+ye\ny0GqierUhR0Vc0RKKbaDAw3i/ppE8xnzSLFzJhIzRnOIHCLQQnUzTwz6WS7inJ6A\n5qJx/qLJn1JZg3XeVAnM7yPNTimYr6TlSgIzNUAGVGarvzSBarHjQsIjncpR0xye\njFgQciRUGyngHDUZHPEhRaCmA0n3",
        "mongodb.initUser" => "init-root",
	"version" => "3.6"
  },
    "cumulocity-external-lb" => {
        "landing_page" => "https://mciotextension.eu1-int.mindsphere.io/apps/devicemanagement",
        "paas_default_page" => "https://$http_host/apps/$defapp/",
        "paas_public_default_page" => "https://mciotextension.eu1-int.mindsphere.io/apps/dmpublic",
        "usePostgresForPaaS" => false,
        "paas_redirection" => true,
        "proxy_cache" => true,
        "useIPAddress" => true,
        "useMQTTsupport" => true,
        "useSSL" => true,
        "force_proto_for_link_processor" => "https",
        "certificate_domain" => "mciotextension.eu1-int.mindsphere.io",
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
   "cumulocity-cep" => {
       "properties" => {
         " esperha.storage" => "/mnt/esperha-storage/"
     },
  }

)

#cookbook_versions(ChefConfig.cookbook_versions_for_env)
