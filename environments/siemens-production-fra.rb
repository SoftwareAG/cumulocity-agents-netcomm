name "siemens-aws-el7-production"

description "The Siemens Mindsphere Frankfurt production multinode environment"

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
  "chef_client" => {
        "server_url" => "https://cumulocity-prod-chef12"
  },
  "domainname" => "mciotextension.eu-central.mindsphere.io",
  'yum' => {
    'proxy' => 'http://172.21.0.57:14239',
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
    "address" => "manage.mciotextension.eu-central.mindsphere.io"
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
     "deployK8S4env" => "siemens-aws-el7-production",
     "attachedEnvs" => ["siemens-aws-el7-production"],
     "docker-registry-image" => "cumulocity/registry:2.6.1",
     "token" => "2xa912.80gkbk4eo10vv0li",
     "images-connString" => "https://K8Simages:K8S^imAgEs5000%@resources.cumulocity.com/kubernetes-images",
#     "images-version" => "9.0.17",
     "images-version" => "9.16.6",
#     "images2install" => [ "cep","cep-small" ]
     "images2install" => [ ]
  },
  "cumulocity-karaf" => {
#    "version" => "8.19.27-1",
#    "version" => "9.8.11-1",
    "version" => "9.16.6-1",
# For lwm2m:
    "ssa-version" => "9.12.18-1",
#    "ssa-version" => "9.16.6-1",
#    "memory_left_for_system" => "2048",
    "memory_left_for_system" => "4096",
    "notification" => true,
    "oort-enabled" => true,
    "cep-server-enabled" => true,
    "CUMULOCITY_LICENCE_KEY" => "31747ac9ee4e400951260921bfd20c680c681f0e5d7408f38813259fd709074c5065d01016649b1965bf66efdcc6a95495150f8efe58a3d6f465b5944d44d09e",
    "openrelayIP" => "email-smtp.eu-west-1.amazonaws.com",
#    "openrelayIP" => "54.171.198.162",
     "openrelayPORT" => "587",
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
      "default.tenant.applications" => "administration,devicemanagement,cockpit,feature-microservice-hosting",
      "management.admin.password" => "fa0c9e480dc8778c5bd4f1fcb7d5325b6459c41bb59494cfe27d643de7a7f940", # insert password
      "tenant.admin.password" => "fa0c9e480dc8778c5bd4f1fcb7d5325b6459c41bb59494cfe27d643de7a7f940", # insert password
      "admin.password" => "fa0c9e480dc8778c5bd4f1fcb7d5325b6459c41bb59494cfe27d643de7a7f940", # insert password
#      "system.files.max.size" => "524288000",
      "system.plugin.eventprocessing.enabled" => false,
      "system.plugin.eventprocessing.forwarding.enabled" => false,
      "system.plugin.eventprocessing.appmodule.enabled" => false,
      #"system.two-factor-authentication.enabled" => false,
      #"system.two-factor-authentication.enforced.group" => "admins",
      #"system.two-factor-authentication.host" => "http://${SMS-GATEWAY-SERVER}:8688/sms-gateway",
      #"system.two-factor-authentication.senderAddress" => "",
      #"system.two-factor-authentication.senderName" => "Siemens",
      #"system.two-factor-authentication.logout-on-browser-termination" => true,
      #"system.two-factor-authentication.max.inactive" => "14",
      #"system.two-factor-authentication.provider" => "<customer>",
      #"system.two-factor-authentication.<customer>.baseUrl" => "https://m1free.rcs.msg.<customer>.com/messaging/v1/sms/outbound/acr%3Acumulocity/requests",
      #"system.two-factor-authentication.<customer>.baseUrl" => "https://free.rcs.<customer>.com/messaging/v1/sms/outbound/acr%3Acumulocity/requests",
      #"system.two-factor-authentication.<customer>.username" => "cumulocity",
      #"system.two-factor-authentication.<customer>.password" => "<smspassword>",
      ##"default.tenant.microservices" => "device-simulator,oc2-data-mapper,oc2-map-config",
      "default.tenant.microservices" => "device-simulator,oc2-data-mapper,oc2-map-config,smartrule,cep,sigfox-agent,feature-cep-custom-rules",
      #"migration.tomongo.default" => "POSTGRES_READ_WRITE",
      "migration.tomongo.default" => "MONGO_READ_WRITE",
      #"tenant.admin.grants.disabled" => true,
      "system.support-user.enabled" => true,
      "tenantSuspend.mail.sendtosuspended" => false,
      #"tenantSuspend.mail.additional.address" => "operations@cumulocity.com",
      "device-simulator.microservice.url" => "http://${DEVICE-SIMULATOR-AGENT-SERVER}:6666",
      "smartrule.microservice.url" => "http://127.0.0.1:8334",
      "email.from" => "no-reply@mciotextension.eu-central-rc.mindsphere.io",
      "errorMessageRepresentationBuilder.includeDebug" => "false",
      "passwordReset.email.subject" => "Password reset",
      "passwordReset.token.email.template" => 'Dear Siemens user,\n\n\
            You or someone else entered this email address when trying to change the password of a Siemens portal user.\n\n\
            Please use the following link to reset your password: \n\
            {host}?token={token}&showTenant\n\n\
            If you were not expecting this email, please ignore it. \n\n\
            Kind regards,\n\
            Siemens support team\n',
      "passwordReset.user.not.found.email.template" => 'Hi there,\n\n\
            you or someone else entered this email address when trying to change the password of a Siemens portal user.\n\n\
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
        'initRunUser' => 'mongod',
        'initRunGroup' => 'mongod',
        #'members-check' => false,
        #"installEnterprise" => true, # migration change
        "wiredtiger-cache" => 8,
        "sharedkey-content" => "XSF8n3qBBbyUZYUWuuShHra9pj8aF2tMXZ/pApCGwtf6o+nl8uJ4RcbR9jzhQcom\nmWxQ8yWy4Q5rbZF6KY+4inJXQ9Z0dRWYJ6TqTRhOF9v9OjySiSVKvQ192KIlggQ4\n/lLkiYt769/aRvPkqE5KgreFxHtxW5AufUBwoCENDSr2gu7O/wLLAahXwg+ZkCeZ\nEZ66XkU6sbuTe1BMLF3jP5FIYfqTkUnfllwYXnnyWfYWChVPF/Uu+nEg3frsb77f\nYrkRZ0pPUEU1m179c6MGLYW7VC4ObrkYHFCQcqfcEJhs+jhp8f/aA1wURe0QbxDA\nOrUkccN7enfv8h8bIfYzH9zFIba3ezvzPefez4R8WngMDh9gIWL2QYpT6cw0r9xb\nZ2mI6T2cvqbw1vXrZCzCfY7HIVE6Ui77dGBsC5E+lK8HTtP5ZxjenF45VPz8ANXD\nKVVmgCTio7muYAma+x9JHcc4SVkWOel60OhwoTum+i1lAB4a8z3kbMrqoKbjZbYb\n3hLoBYZDbj0mg77SNvge2Eiw56oHQW6Hl93H79bQsZi/mGFfRVpQwoeZAe6jJStn\n7eUnVvlB8BrTa85rafOuyZqSbSfL/NMtQiiDdvtBpxl7ySQVeT0XkSc2NJE6j4RZ\nVl/xVJKqpsZJEcxXO9TfIue6fbEjt+GzAMCoLcfetIbnBRnpGdpRjnnCndgz2v+6\nzDXaFvO6ZEV8L6HwwgZGT08FNs4dubW1Tb+RffIRYrok/uqBsQHATmi6ddRdVHNd\nLTL/TJ6Evp2k1+2KmP5AOA7vgtoHNBSEJF3HW68WidTli4GyHCRT1zjld+EL2+ye\ny0GqierUhR0Vc0RKKbaDAw3i/ppE8xnzSLFzJhIzRnOIHCLQQnUzTwz6WS7inJ6A\n5qJx/qLJn1JZg3XeVAnM7yPNTimYr6TlSgIzNUAGVGarvzSBarHjQsIjncpR0xye\njFgQciRUGyngHDUZHPEhRaCmA0n3",
        "mongodb.initUser" => "init-root",
        "version" => "3.6"
  },
    "cumulocity-external-lb" => {
        "landing_page" => "https://mciotextension.eu-central.mindsphere.io/apps/devicemanagement",
        "paas_default_page" => "https://$http_host/apps/$defapp/",
        "paas_public_default_page" => "https://mciotextension.eu-central.mindsphere.io/apps/dmpublic",
        "usePostgresForPaaS" => false,
        "paas_redirection" => true,
        "proxy_cache" => true,
        "useIPAddress" => true,
        "useMQTTsupport" => true,
        "useMQTTlogs" => true,
        "useSSL" => true,
        "force_proto_for_link_processor" => "https",
        "certificate_domain" => "mciotextension.eu-central-rc.mindsphere.io",
        "temp_chunkin" => false,
        "useKarafWebsocket" => true,
	"useLUAforSSLcerts" => nil,
	"useLUAforLimits" => true,
	"useLUAforHealthCheck" => true,
        "nginx" => {
            "NGinxPort" => "openresty",
             "version" => "1.13.6.1-20.el7.centos.c8y.8.11.1" # migration change
        }
  },
    'cumulocity-rsyslog' => {
      'log-server-ext-address' => '172.21.0.138',
      'CAfile' => '/etc/pki/tls/certs/ca-bundle.crt',
#      'cross-env-log-server' => "siemens-fra-prod",
       'log-server-role' => "siemens-syslog-ng-monitoring-part"
  },
   "cumulocity-cep" => {
       "properties" => {
         " esperha.storage" => "/mnt/esperha-storage/"
     },
  },

    'cumulocity-ssagents' => {
      'useTags' => true
    },

 'lwm2m-agent' => {
          'subscriptions_fetch_delay' => 60000,
          'device-tenant_mapping_reload_delay' => 60000,
          'host_fwUpdate' => "18.196.157.82",
          'C8Y_lwm2mEventLoggingEnabled' => true,
          'leshan_cluster_tenant' => "management",
          'leshan_cluster_tenant_username' => "lwm2m-user",
          'leshan_cluster_tenant_password' => "zaeVee1prodJIe4yam"
        },

  "postfix" =>    {
        "smtp_sasl_auth_enable" => true,
        "smtp_sasl_security_options" => "noanonymous",
        "smtp_relay_username" => "AKIAJI6ZRJ5M4ZDRGHVQ",
        "smtp_relay_password" => "sHKomTOYYTATA4OMoq2a3SUxAZgC9Ex2bLK4TIwjEWg"
        },

)

#cookbook_versions(ChefConfig.cookbook_versions_for_env)
