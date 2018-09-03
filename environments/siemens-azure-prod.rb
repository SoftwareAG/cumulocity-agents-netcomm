name "siemens-azure-prod"

description "The Siemens Mindsphere Azure production multinode environment"

default_attributes(
 "elb" => {
      "name" => "production"
    },
#  "cumulocity-core" => {
#    "properties" => {
#      "sysadmin.username" => "<user>@<domain_name>",
#      "sysadmin.role" => "SYSTEM",
#      "default.tenant.applications" => "administration,devicemanagement,cockpit",
#      "auth.checkBlockingFromOutside" => true
#    }
# }
)
override_attributes(
   "chef_client" => {
        "server_url" => "https://ng-iotextensionchef12"
  },
#  "nagios" => {
#    "server" => {
#        "version" => "3.4.3",
#        "checksum" => "adb04a255a3bb1574840ebd4a0f2eb76"
#        }
#    },

  "domainname" => "mciotextension.eu2.mindsphere.io",

  'yum' => {
    'repositories' => {
      'cumulocity-testing' => {
        'enabled' => "0"
      },
        'cumulocity-ext' => {
            'url' => "https://cumulocity:ACceP=m+2m@yum.cumulocity.com/centos/7/cumulocity/x86_64/",
            'name' => "cumulocity",
            'description' => "Cumulocity Repository",
            'enabled' => "1",
            'sslverify' => "0"
            }
    }
  },
  "environment" => {
    "address" => "manage.mciotextension.eu2.mindsphere.io"
  },
  "java" => {
     "jdk_version" => "8"
  },

  "cumulocity-kubernetes" => {
     "deployK8S4env" => "siemens-azure-prod",
     "attachedEnvs" => ["siemens-azure-prod"],
     "token" => "r1sneg.v5gujy9cfl39aoqz",
     "images-connString" => "https://K8Simages:K8S^imAgEs5000%@resources.cumulocity.com/kubernetes-images",
     "images-version" => "9.0.21",
     "images2install" => [ "" ]
  },

  "cumulocity-karaf" => {
    "version" => "9.0.21-1",
#    "ssa-version" => "8.15.5-1",
    "management-access" => [ "127.0.0.1" ],
    "memory_left_for_system" => "1836",
    "notification" => true,
    "oort-enabled" => true,
     "CUMULOCITY_LICENCE_KEY" => "ac37d9d4800a8d41a3bf06c22ca9566379bd315a549e8c29bf2399b48ad042277696f0476d6247078e3fdeb51480ff5777a3636278362c0f1b4a3892aa2f49aa",
    "cep-server-enabled" => false,
     #"openrelayIP" => "email-smtp.eu-west-1.amazonaws.com",
     "openrelayIP" => "34.240.50.108",
     "openrelayPORT" => "587",
      "karaf" => {
        "memory" => {
            "xms" => "1024M"
            }
        }
  },
  "cumulocity-mongo" => {
        'initRunUser' => 'mongod',
        'initRunGroup' => 'mongod',
        #'members-check' => false,
        #"installEnterprise" => true, # migration change
        "wiredtiger-cache" => 4,
        "sharedkey-content" => "TEFU+OsXpP2neL/8dMgm6c/IL22YyCTkhHs08Ed/TMUNmJg8LN/39MjbBjMYeBIJ\nYpvXapR1xRgg6lWdKSTF/vFu3hLCvaPtlEEQm3XHiO45SEZCAFLMNT5XV310AvBA\nNVITwxJ5G2gV1XhJWaQdqOlyd2RKJs8iVvDSNQpQBsMp7Ds74sKNf3dpAcIhS4aK\nrhlNHVAijhuveYDmvfp+r2w5VlqwsVzGV0DoUhpQ3K0X1hHJC46nd8MlJ7VbF4H3\nhNdLsQoosW29mi1JuSXCk8hntDGgeCtdZwQZzJ8FfqnRab9+NvfpPXbkD3u1L5HA\ngKoVyceLOou4kNKC9B+AnGOl7bcRR/jl51b3F22L+Yiq/9kidGHGkib1GxZ6mi3a\n4+5abkV32w2RZcsLYVmc4+RRKGI6x553qJ67fKnPUDhDdnoAOnMMxm0/28SLkuKn\nj75JRyHZ7IlxRzGU1uyFrEHYo+OneH6AydUjgSxWNeafuk0LCkeRT2b+uaGaIJiL\ng69i6WRtKh2l58E5HOUN9RhuBNEuMT6hKcFV+bOD06dPp1hwD+DE8lXCic+dzDTi\n+yIk5K6jp4brWMePtuaU0aWpT38DsjCNTwz48HNoo0PLtPo10EkZK7cGdn3RWbHm\njUdxenHeGtlzA+6rjS53stG4JFV/FWAOB6s/KuTKFp+xMaVLwAg8CYPey1plvzuR\nzeyxVAVyAtWTjEZ1iHml7zQsWEk4xkzB5JHJ0IT8qLOyVxOue9eJsiLp8kP7h97g\ncMdCxzynTZ1Dvlduy8LW/7pbpCZQ2dluonv90WfReFz7k3nKQQkrEGcQgoFHXqrj\nX4MoPibjlPAuDm8jG1ucleXfugdNYB1Zc+iJc+sp+8sz8Ij/bE3dGxu8DrVzVJZE\nGUkiKP6u94YVrX6jnLZSnENegfO5bu3/3GNMT+F6aWgPJBRpjj8VHhLLkAAt1nGT\nMWYXBPZGS2TF/L4OMIfCEQ7tbAuc",
        "mongodb.initUser" => "init-root",
#       "mongodb.initPassword" => "myDIFE-ho49"
  },
  "cumulocity-core" => {
    "properties" => {
#     "contextService.rdbmsURL" => "jdbc:postgresql://localhost",
#     "contextService.rdbmsDriver" => "org.postgresql.Driver",
#     "contextService.rdbmsUser" => "postgres",
#     "contextService.rdbmsPassword" => "JaDymyny5-0",
#     "mongodb.host" => "localhost",
      "mongodb.user" => "c8y-root",
#     "mongodb.password" => "PoSuBU-VI07",
      "mongodb.admindb" => "admin",
      "contextService.tenantManagementDB" => "management",
	#pass: GiMUJYbE80
      "management.admin.password" => "2327347ea05b13d6d835facc1cd4d63626416fced7640cac13653a6bd5644b5c",
      "tenant.admin.password" => "2327347ea05b13d6d835facc1cd4d63626416fced7640cac13653a6bd5644b5c",
      "admin.password" => "2327347ea05b13d6d835facc1cd4d63626416fced7640cac13653a6bd5644b5c",
      "cumulocity.environment" => "PRODUCTION",
      "auth.checkBlockingFromOutside" => "false",
      "errorMessageRepresentationBuilder.includeDebug" => "false",
      "default.tenant.applications" => "administration,devicemanagement,cockpit,feature-microservice-hosting,feature-cep-custom-rules",
#      "default.tenant.microservices" => "device-simulator, smartrule, cep, feature-microservice-hosting, feature-cep-custom-rules",
      "default.tenant.microservices" => "device-simulator",
      "migration.tomongo.default" => "MONGO_READ_WRITE",
#     "device-simulator.microservice.url" => "http://${DEVICE-SIMULATOR-AGENT-SERVER}:6666",
      "device-simulator.microservice.url" => "http://127.0.0.1:6666",
#      "smartrule.microservice.url" => "http://172.21.2.160:8334",
      "cometd.heartbeat.minutes" => "5",
      "system.plugin.eventprocessing.enabled" => false,
      "system.plugin.eventprocessing.forwarding.enabled" => false,
      "system.plugin.eventprocessing.appmodule.enabled" => false,
      "email.from" => "admin@mciotextension.eu2.mindsphere.io",
      "passwordReset.email.subject" => "Password reset",
      "passwordReset.token.email.template" => 'Dear Siemens Mindsphere user,\n\n\
            You or someone else entered this email address when trying to change the password of a Siemens Mindsphere portal user.\n\n\
            Please use the following link to reset your password: \n\
            {host}?token={token}\n\n\
            If you were not expecting this email, please ignore it. \n\n\
            Kind regards,\n\
            Siemens Mindsphere support team\n',
      "passwordReset.user.not.found.email.template" => 'Hi there,\n\n\
            you or someone else entered this email address when trying to change the password of a Siemens Mindsphere portal user.\n\n\
            However, we could not find the email address in your account. Please contact the administrator of your \
            account to set your email address and password. If you are the administrator of the account,\
            please use the email address that you registered with.\n\n\
            If you were not expecting this email, please ignore it. In case of questions, please get in contact with the administrator of Siemens Mindsphere portal. \n\n\
            Kind regards,\n\
            Siemens Mindsphere support team\n',
      "passwordReset.success.email.template" => 'Dear Siemens Mindsphere user,\n\n\
            Your password on {host} has been recently changed. \n\
            If you or your administrator made this change, you do not need to do anything more. \n\
            If you did not make this change, please contact your administrator.\n\n\
            Kind regards,\n\
            Siemens Mindsphere support team\n',
      "passwordReset.invite.template" => 'Hi there,\n\n\
            Please use the following link to reset your password: \n\
            {host}/apps/devicemanagement/index.html?token={token}\n\n\
            If you were not expecting this email, please ignore it. \n\n\
            Kind regards,\n\n\
            Siemens Mindsphere support team\n'
    }
  },

    "cumulocity-external-lb" => {
        "landing_page" => "https://mciotextension.eu2.mindsphere.io/apps/devicemanagement/",
        "paas_default_page" => "https://$http_host/apps/$defapp",
        "paas_public_default_page" => "https://mciotextension.eu2.mindsphere.io/apps/dmpublic",
        "usePostgresForPaaS" => false,
        "paas_redirection" => true,
        "proxy_cache" => true,
        "useIPAddress" => true,
        "useSSL" => true,
#       "certificate_domain" => "acme.com",
        "certificate_domain" => "mciotextension.eu2.mindsphere.io",
        "temp_chunkin" => false,
        "useKarafWebsocket" => true,
        "useMQTTsupport" => true,
        "useLUAforSSLcerts" => nil,
        "useLUAforLimits" => true,
        "useLUAforHealthCheck" => true,
	"nginx" => {
            "NGinxPort" => "openresty",
            "version" => "1.11.2.4-20.el7.centos.c8y.8.11.1"
        }
    },
    "cumulocity-internal-lb" => {
        "mongodb" => true
       },

"postfix" =>	{
	"smtp_sasl_auth_enable" => true,
	"smtp_sasl_security_options" => "noanonymous",
	"smtp_relay_username" => "AKIAJW2MXH3V6FLSKCSA",
	"smtp_relay_password" => "AlilKOfZB0JT/+zNgLzwLbzwOkOUkPvCtIoH0sm/ORqc"
	},

    'cumulocity-rsyslog' => {
#      'cross-env-log-server' => "cumulocity-multinode-prod",
#      'log-server-ext-address' => "monitoring.cumulocity.com"
  },

  "cumulocity-cep" => {
       "properties" => {
         #"version" => "8.19.13-1",
         " esperha.storage" => "/mnt/esperha-storage/"
     },
  },

#  "cumulocity-ssagents" => {
#	"useTags" => true,
#    "ssAgentsIP" => "10.10.2.4"
#  }

)
#cookbook_versions(ChefConfig.cookbook_versions_for_env)
