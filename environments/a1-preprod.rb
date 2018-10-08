name "a1-preprod"

description "The A1.digital staging aka. pre-production multinode environment"

default_attributes(
 "elb" => {
      "name" => "production"
    },
)
override_attributes(
   "chef_client" => {
        "server_url" => "https://ng-iotextensionchef12"
  },
  "domainname" => "iotstg.a1.digital",
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
    "address" => "manage.iotstg.a1.digital"
  },
  "java" => {
     "jdk_version" => "8"
  },

  "cumulocity-kubernetes" => {
     "deployK8S4env" => "a1-preprod",
     "attachedEnvs" => ["a1-preprod"],
     "token" => "k79xm2.ad277zsafl9q38o9",
     "images-connString" => "https://K8Simages:K8S^imAgEs5000%@resources.cumulocity.com/kubernetes-images",
     "images-version" => "9.8.8", # check
     "images2install" => [ "" ]
  },

  "cumulocity-karaf" => {
##    "version" => "9.8.8-1",
    "version" => "9.8.10-1",
    "ssa-version" => "9.8.8-1",
    "management-access" => [ "127.0.0.1" ],
    "memory_left_for_system" => "1836",
    "notification" => true,
    "oort-enabled" => true,
    "cep-server-enabled" => true,
	# iotstg.a1.digital
     "CUMULOCITY_LICENCE_KEY" => "52e243aa993773ea1b291e89e7fe98a94a4afd101b9d75da752abd9b46c0b8e52d5ad8c26f682765ac06cc0f24a5d5d996965847d88d1b1ce5852e1ff0cb6e34",
#     "openrelayIP" => "email-smtp.eu-west-1.amazonaws.com", # check
#     "openrelayPORT" => "587", # check
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
        "sharedkey-content" => "pZw+GpYoahiN85t4UJW/YY5GOuhssCPW9JdxmE6jzHproHdBmPNnC8bpMHgVScu8\nKXwOY54WkExhVGfAntScHkcm/bt2gAuGgnaApooiXzQi7h4UFXSfNo9M+xcFQ+G2\nH8UaSqC1fx39Os7z1UrXpm1YhliaBQTCLpkEHG4jm7ek/W/5XPqOfGS/pwMWTa6h\n5t77C02bEZg+xMNfeDZF4KcANGVXy+7+7OWVoPK/xxjjUkm4bym+qq9jXF05osvZ\nkDLU2T/8fe0lJFCDjTAIhHbrvir1LrkbK5Bm2h/D5uqcCNQguiG38WF3XWIRIRGf\ny4+X9leZo9Xs15GVswGlo81UzFMlA6eTVjmwmU9QjH+eU2Ef3daPxBdudc6RrI9M\ne0Y3DduyYwmi7si+MugsO7jpMzk723fVsQHL7s20cuikQTrk5IzGiYsmouIGrpaW\n+hhKOfc9LvBrinaAVCo8K1yY4eKgrvFs0LDGyqc7lhJ42KLdghedEmsUsw/BbW39\nUsgbIHQEKqknfbpHDbm+ezHCxexGM+7xyx/s/X1rJx+vUrOW1a/1aSv7V9+QLUlq\nM/tEx4R9X1X8G/J2gClVEAW7BE90qRve98JsjRh9h3mYsFO9FMJRSYdjggIgTN6P\nk2yJDRoTwQ+eBXjCW9O74OIewQTSqkaQVsqgNn6OSVOikFUOL0TK1KzSvjO4X1Me\nKgtOUDTTZmucykhEsbOJ8itP81DbTtDkVcp1+YAYJKt2To9KHJ5fn5/gSZYljT22\neTf88ERSaco4gRPf2e1nOVx0NydlaXW8O8kEOuBuDZ8VIVjul6GEvnjXjF6Y59VU\ntc0Bot+DtI4HAs9X/myQTTDVwonN0xb3s0MMpcvCNz1MxkSwHJWVjRWPgygL6iOZ\nrnpjlCyuvgG30vWdDykOuqi9O1ZuVdEFjM4qMv+cKRl8A9MC0O2RgVvUgVfb8EaL\n+dss4UYqi0dc0CjjjyBj5ZOfHwQl",
        "mongodb.initUser" => "init-root",
  },

  "cumulocity-core" => {
    "properties" => {
      "contextService.rdbmsURL" => "jdbc:postgresql://localhost",
      "contextService.rdbmsDriver" => "org.postgresql.Driver",
      "contextService.rdbmsUser" => "postgres",
      "mongodb.user" => "c8y-root",
      "mongodb.admindb" => "admin",
      "contextService.tenantManagementDB" => "management",
	#pass: A1.c8y.dD1q1t4U
      "management.admin.password" => "f8aa4fe9d57051e49d0bd1a48de5866bde26c8b9f9c9b57ea6bbe3ffbd0e44bd",
      "tenant.admin.password" => "f8aa4fe9d57051e49d0bd1a48de5866bde26c8b9f9c9b57ea6bbe3ffbd0e44bd",
      "admin.password" => "f8aa4fe9d57051e49d0bd1a48de5866bde26c8b9f9c9b57ea6bbe3ffbd0e44bd",
      "cumulocity.environment" => "PRODUCTION",
      "auth.checkBlockingFromOutside" => "false",
      "errorMessageRepresentationBuilder.includeDebug" => "false",
      "default.tenant.microservices" => "device-simulator, smartrule, cep, feature-microservice-hosting, feature-cep-custom-rules",
      "default.tenant.applications" => "administration,devicemanagement, cockpit,feature-microservice-hosting,feature-cep-custom-rules",
      "migration.tomongo.default" => "MONGO_READ_WRITE",
      "device-simulator.microservice.url" => "http://127.0.0.1:6666",
      "smartrule.microservice.url" => "http://172.21.2.160:8334",
      "microservice.websocket.port" => 8303,
      "passwordReset.email.subject" => "Password reset",
      "system.plugin.eventprocessing.enabled" => false,
      "system.plugin.eventprocessing.forwarding.enabled" => false,
      "system.plugin.eventprocessing.appmodule.enabled" => false,
      "system.support-user.enabled" => true,
      "tenantSuspend.mail.sendtosuspended" => false,
      "email.from" => "no-reply@stacum.exoat1",
      "passwordReset.token.email.template" => 'Dear A1.digital PreProduction user,\n\n\
            You or someone else entered this email address when trying to change the password of an A1.digital preprod portal user.\n\n\
            Please use the following link to reset your password: \n\
            {host}?token={token}\n\n\
            If you were not expecting this email, please ignore it. \n\n\
            Kind regards,\n\
            the A1.digital support team\n',
      "passwordReset.user.not.found.email.template" => 'Hi there,\n\n\
            you or someone else entered this email address when trying to change the password of an A1.digital preprod portal user.\n\n\
            However, we could not find the email address in your account. Please contact the administrator of your \
            account to set your email address and password. If you are the administrator of the account,\
            please use the email address that you registered with.\n\n\
            If you were not expecting this email, please ignore it. In case of questions, please get in contact with the administrator of the A1.digital preprod portal. \n\n\
            Kind regards,\n\
            the A1.digital support team\n',
      "passwordReset.success.email.template" => 'Dear A1.difital preprod user,\n\n\
            Your password on {host} has been recently changed. \n\
            If you or your administrator made this change, you do not need to do anything more. \n\
            If you did not make this change, please contact your administrator.\n\n\
            Kind regards,\n\
            the A1.digital support team\n',
      "passwordReset.invite.template" => 'Hi there,\n\n\
            Please use the following link to reset your password: \n\
            {host}/apps/devicemanagement/index.html?token={token}\n\n\
            If you were not expecting this email, please ignore it. \n\n\
            Kind regards,\n\n\
            the A1.digital support team\n'
    }
  },

    "cumulocity-external-lb" => {
        "landing_page" => "https://mciotextension.eu2-rc.mindsphere.io/apps/devicemanagement/",
        "paas_default_page" => "https://$http_host/apps/$defapp",
        "paas_public_default_page" => "https://mciotextension.eu2-rc.mindsphere.io/apps/dmpublic",
        "usePostgresForPaaS" => false,
        "paas_redirection" => true,
        "proxy_cache" => true,
        "useIPAddress" => true,
        "useSSL" => true,
        "useMQTTsupport" => true,
        "force_proto_for_link_processor" => "https",
#       "certificate_domain" => "cumulocity.com",
        "certificate_domain" => "iotstg.a1.digital",
        "temp_chunkin" => false,
        "useKarafWebsocket" => true,
        ##"useLUAforSSLcerts" => nil,
        "useLUAforSSLcerts" => true,
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

#    'cumulocity-rsyslog' => {
#      'cross-env-log-server' => "cumulocity-multinode-prod",
#      'log-server-ext-address' => "monitoring.cumulocity.com"
#  },

  "cumulocity-cep" => {
       "properties" => {
         " esperha.storage" => "/mnt/esperha-storage/"
     },
  },

#  "cumulocity-ssagents" => {
#	"useTags" => true,
#    "ssAgentsIP" => "10.10.2.4"
#  }

    'cumulocity-ssagents' => {
     "useTags" => true,
        "sslmanagement" => {
          "salt" => "81643379eb0ca927",
          "password" => "3bb50705293bcba3",
        },
 	"lwm2m-agent" => {
 	  "host_fwUpdate" => "185.150.8.239",
 	  ##"leshan_cluster_tenant" => "management",
 	  "leshan_cluster_tenant" => "lwm2mbase",
 	  "leshan_cluster_tenant_username" => "lwm2m_user",
 	  "leshan_cluster_tenant_password" => "passw0rd_a"
        },
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
