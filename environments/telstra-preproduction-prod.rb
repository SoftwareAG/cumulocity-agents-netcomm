name "telstra-preproduction-prod"

description "The Telstra Preproduction environment"

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
        "server_url" => "https://c8y-preprod-chef12"
  },
  "domainname" => "iotpreprod.telstra.com",
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
    "address" => "iotpreprod.telstra.com"
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
     "deployK8S4env" => "telstra-preproduction-prod",
     "attachedEnvs" => ["telstra-preproduction-prod"],
     "token" => "1e3145.2ff901841c48af2e",
     "images-connString" => "https://K8Simages:K8S^imAgEs5000%@resources.cumulocity.com/kubernetes-images",
     "images-version" => "8.19.15",
     "images2install" => [ "cep" ]
  },
  "cumulocity-karaf" => {
    ## "version" => "8.7.5-1",
    "version" => "8.19.15-1",
    "memory_left_for_system" => "2048",
    "notification" => true,
    "oort-enabled" => true,
    "cep-server-enabled" => true,
    "CUMULOCITY_LICENCE_KEY" => "7c5f10ec052f2260a214680034f97b1f1777030f1ea27be17e5d80a46419b8cd5425d02d95c026b08999f77fd87836d4f13b2e63595cc457b3ced51cdfacdaef"
  },
  "cumulocity-core" => {
    "properties" => {
      "contextService.rdbmsURL" => "jdbc:postgresql://localhost",
      "contextService.rdbmsDriver" => "org.postgresql.Driver",
      "contextService.rdbmsUser" => "postgres",
#      "contextService.rdbmsPassword" => "tel1506STRA",
      "system.connectivity.microservice.url" => "http://192.168.17.34:8092/jwireless",
      "smsGateway.host" => "http://192.168.17.34:8688/sms-gateway",
      "mongodb.user" => "c8y-root",
#      "mongodb.password" => "tel1506STRA",
      "mongodb.admindb" => "admin",
      "contextService.tenantManagementDB" => "management",
      "cumulocity.environment" => "PRODUCTION",
      "auth.checkBlockingFromOutside" => false,
#            "errorMessageRepresentationBuilder.includeDebug" => "false",
      "default.tenant.applications" => "administration,devicemanagement,cockpit",
      "management.admin.password" => "5abf4845cb3478e00c1c02825e950e3ee057c85165ae3c9b733b82b88e562614",
      "tenant.admin.password" => "5abf4845cb3478e00c1c02825e950e3ee057c85165ae3c9b733b82b88e562614",
#      "admin.password" => "5abf4845cb3478e00c1c02825e950e3ee057c85165ae3c9b733b82b88e562614",
      "admin.password" => "4a893cafa79e1dd5a028a062d021994201c06eeaa463cc598a75fa88a95623af",
      "system.two-factor-authentication.enabled" => false,
      #"system.two-factor-authentication.enforced.group" => "admins",
      "system.two-factor-authentication.host" => "http://${SMS-GATEWAY-SERVER}:8688/sms-gateway",
      "system.two-factor-authentication.senderAddress" => "+61418368753",
      "system.two-factor-authentication.senderName" => "Telstra IoT",
      "system.two-factor-authentication.logout-on-browser-termination" => true,
      "system.two-factor-authentication.max.inactive" => "14",
      "system.two-factor-authentication.provider" => "telstra",
      #"system.two-factor-authentication.telstra.baseUrl" => "https://m1free.rcs.msg.telstra.com/messaging/v1/sms/outbound/acr%3Acumulocity/requests",             
      "system.two-factor-authentication.telstra.baseUrl" => "https://free.rcs.telstra.com/messaging/v1/sms/outbound/acr%3Acumulocity/requests",             
      "system.two-factor-authentication.telstra.username" => "cumulocity",                                                                                        
      "system.two-factor-authentication.telstra.password" => "xBg5Wa8M",                                                                                          
      "default.tenant.microservices" => "device-simulator, smartrule, cep",
      "migration.tomongo.default" => "MONGO_READ_WRITE",
      #"tenant.admin.grants.disabled" => true,
      "system.support-user.enabled" => false, 
      "tenantSuspend.mail.sendtosuspended" => false,
      "tenantSuspend.mail.additional.address" => "operations@cumulocity.com",
      "device-simulator.microservice.url" => "http://${DEVICE-SIMULATOR-AGENT-SERVER}:6666",
      "smartrule.microservice.url" => "http://${SMARTRULE-AGENT-SERVER-ESPER}:8334",
      "email.from" => "no-reply@iotpreprod.telstra.com",
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
        'members-check' => false,
        "installEnterprise" => true, # migration change
        "wiredtiger-cache" => 2,
        "sharedkey-content" => "aFd8w+psznnJMULj6Vtr6Jc1pPg+ALVMAM01eD3zUzCB9VTHKOWFFp26qVNkmle5\nmLM45Igfe2mGsloyHYgSJDOe8yFPQD5CVGQhczel6NonN+5eTfn63PerKYADLVoG\nI1l7PhJoiLrqgJpSxtZAN8TidX9g37GXHiJ2ND8pJMs0FE0MS2cWLBljbJJy61ie\nRrXk2X6lb/8Cm8SobOxngZ61P/63pb6NyjRh2SkDFIysqpdaT4zIafzA4aZVRUlr\nyfID8JWSkqYYY6uMDDrqU1AZcbqMYBfCRH6YjLPfrTi6LlpRKV8sQhsAyYNfOYOn\n0tgZEeMUxTVtw3nBqrUYXBDDiO1iq+eQBVF/lY5lX1GRn/J/8Ih/N9l2bhiLjBEE\nZ3+KT3imQw+yYC2jVyS81GUyXwwoTWdYwGkrh4aszhwxpieh2kx/7JX1Ch/n9VmZ\n0VFeRCmA7Gna+BeJtVtYSFC11zf5Jb/NN5nl/genzTdPGQGTLqGcaUFbX3a4rtJh\nZnAn8FJBQl9PUgjPhWzdQDIGdC+Q3oB02nfYkLbcBFXtaO4peqAsBfr2+CBAT661\negPlB9mGr8lIRjJG28lwzIB3xhlYiFPTMXobtt40yF2omaz1HryjONopPLV2lk0l\nFL+vuI6FVhNHEltXPbIfNCiu8SCEHhIe1zmDxeyx/aXydsU0aOdm9YVhLs5XKxcr\n7JOaPtUKNx4atuocsl7z/LGo3Qo72Rnh/84kv7NL0P7DxzGOmmernvI/WMcK4IJ0\nWrrMji+gBvlyTcXV2BXsG8Bm9sedXWb4cREKVwvwrKxU7htUXyHwLKd4szfshUlp\nONNZNhgBVZWo70hIGldBNZ0bc7C7mmRm3cwK1O14eEP675IkHBz/b8uxCxbs3mlx\n3amMlzEspZG+VmXC/8cXZFy9JmjVEBoH2VTHciHbt/F+qs4bvlYvNh1mQ0Tww1oV\n+7zN5rQiC44MQ/ZB6/KoAqC/IzUz",
        "mongodb.initUser" => "init-root",
        "mongodb.initPassword" => "tel1506STRA"
  },
    "cumulocity-external-lb" => {
        "landing_page" => "https://iotpreprod.telstra.com/apps/devicemanagement",
        "paas_default_page" => "https://$http_host/apps/$defapp/",
        "paas_public_default_page" => "https://iotpreprod.telstra.com/apps/dmpublic",
        "usePostgresForPaaS" => false,
        "paas_redirection" => true,
        "proxy_cache" => true,
        "useIPAddress" => true,
        "useMQTTsupport" => true,
        "useSSL" => false,
        "force_proto_for_link_processor" => "https",
        "certificate_domain" => "staging.c8y.io",
        "temp_chunkin" => false,
        "useKarafWebsocket" => true,
	"useLUAforSSLcerts" => nil,
	"useLUAforLimits" => true,
	"useLUAforHealthCheck" => true,
        "nginx" => {
            "NGinxPort" => "openresty",
#            "version" => "1.11.2.4-20.el6.c8y.8.7.2"
             "version" => "1.11.2.4-20.el7.centos.c8y.8.11.1" # migration change
        }
  },
    'cumulocity-rsyslog' => {
      'cross-env-log-server' => "cumulocity-multinode-prod",
      'log-server-ext-address' => "monitoring.cumulocity.com"
  },
   "cumulocity-cep" => {
       "properties" => {
         " esperha.storage" => "/mnt/esperha-storage/"
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
