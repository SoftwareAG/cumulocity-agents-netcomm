name "cumulocity-multinode-us-west-2-prod"

description "The production multinode environment in Oregon"

cookbook_versions({
#'cumulocity'=>'= 9.20.2',
#'cumulocity-kubernetes'=>'= 9.20.2',
#'cumulocity-ssagents'=>'= 9.20.2'
})

default_attributes(
# "fixhostname" => false,
# "fixhostsfile" => false,
# "fixhostname" => true,
# "fixhostsfile" => true,
 "elb" => {
      "name" => "production"
    }
)
override_attributes(
#  "chef_client" => {
#        "server_url" => "https://chef12.cumulocity.com"
#  },
  "domainname" => "us.cumulocity.com",
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
    "address" => "cumulocity.com"
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
     "docker" => {
       "limits" => {
         "cpu" => "4",
         "memory" => "8Gi"
       },
       "log" => {
         "on-file" => true
       }
     },
     "deployK8S4env" => "cumulocity-multinode-us-west-2-prod",
     "attachedEnvs" => ["cumulocity-multinode-us-west-2-prod"],
     "token" => "mbxfys.reloo224q7b55iy5",
     "docker-registry-image" => "cumulocity/registry:2.7.1",
     "images-connString" => "https://K8Simages:K8S^imAgEs5000%@resources.cumulocity.com/kubernetes-images",
     "images-version" => "9.19.2",
#     "images2install" => [ "cep" ]
     "images2install" => [ "" ]
  },
  "cumulocity-karaf" => {
    #"version" => "9.19.2-1",
# 21.12.2018:
    #"version" => "9.19.3-1",
# 28.12.2018
    #"version" => "9.19.5-1",
# 04.01.2019
    #"version" => "9.19.6-1",
# 18.01.2019
    #"version" => "9.20.4-1",
# 17.04.2019
    #"version" => "1004.0.6-1",
# 05.08.2019
    "version" => "1004.6.8-1",
    #"ssa-version" => "9.20.3-1",
    "ssa-version" => "1004.6.8-1",
    "memory_left_for_system" => "8192",
    "management-access" => [ "172.31.10.100","172.31.10.104","54.247.122.134","100.64.241.0/24", "10.10.0.0/16" ],
    "notification" => true,
    "oort-enabled" => true,
    "cep-server-enabled" => true,
    "revDNSname" => "cepfra.cumulocity.com",
#    "openrelayIP" => "cepfra.cumulocity.com",
    "openrelayIP" => "52.58.146.111",
    "CUMULOCITY_LICENCE_KEY" => "6dfa631bb10f97571f0872cb53e1f31a751da6cdce8491bce51cc9cbbc9d01154bd0477c8037830c02d5c659f5ddd184f86f11cd97aae3ca05ba364d0abb51c0"
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
      "auth.checkBlockingFromOutside" => true,
#            "errorMessageRepresentationBuilder.includeDebug" => "false",
      "default.tenant.applications" => "administration,devicemanagement,cockpit",
      "management.admin.password" => "8c4f94954348ce4770c76d63e5ed6139f06fb08c9790b45ca8c32772551824f2", # ZegAd?yLa78
      "tenant.admin.password" => "8c4f94954348ce4770c76d63e5ed6139f06fb08c9790b45ca8c32772551824f2", # ZegAd?yLa78
      "admin.password" => "8c4f94954348ce4770c76d63e5ed6139f06fb08c9790b45ca8c32772551824f2", # ZegAd?yLa78
      #"system.two-factor-authentication.enabled" => false,
      #"system.two-factor-authentication.enforced.group" => "admins",
      #"system.two-factor-authentication.host" => "http://${SMS-GATEWAY-SERVER}:8688/sms-gateway",
      #"system.two-factor-authentication.senderAddress" => "",
      #"system.two-factor-authentication.senderName" => "Cumulocity",
      #"system.two-factor-authentication.logout-on-browser-termination" => true,
      #"system.two-factor-authentication.max.inactive" => "14",
      #"system.two-factor-authentication.provider" => "<customer>",
      #"system.two-factor-authentication.<customer>.baseUrl" => "https://m1free.rcs.msg.<customer>.com/messaging/v1/sms/outbound/acr%3Acumulocity/requests",             
      #"system.two-factor-authentication.<customer>.baseUrl" => "https://free.rcs.<customer>.com/messaging/v1/sms/outbound/acr%3Acumulocity/requests",             
      #"system.two-factor-authentication.<customer>.username" => "cumulocity",                                                                                        
      #"system.two-factor-authentication.<customer>.password" => "xBg5Wa8M",                                                                                          
#      "default.tenant.microservices" => "device-simulator, smartrule, cep",  <--for 8.19
#      "migration.tomongo.default" => "MONGO_READ_WRITE", <--for 8.19
#      "default.tenant.microservices" => "device-simulator, smartrule, cep",
#      "default.tenant.microservices" => "device-simulator, jwireless, sms-gateway",
#	Added 18.01.2019
      "default.tenant.microservices" => "device-simulator, jwireless, sms-gateway, smartrule, cep",
      "migration.tomongo.default" => "MONGO_READ_WRITE",
      #"tenant.admin.grants.disabled" => true,  
      "system.support-user.enabled" => true, 
      "tenantSuspend.mail.sendtosuspended" => false,
      #"tenantSuspend.mail.additional.address" => "operations@cumulocity.com",
      "microservice.websocket.port" => 8303,
#      "device-simulator.microservice.url" => "http://${DEVICE-SIMULATOR-AGENT-SERVER}:6666",
#      "smartrule.microservice.url" => "http://127.0.0.1:8334",
##      "speechAgent.baseURL" => "${SPEECH-AGENT-SERVER}:8030",
##      "smsGateway.host" => "http://${SMS-GATEWAY-SERVER}:8688/sms-gateway",
##      "system.connectivity.microservice.url" => "http://${JWIRELESS-AGENT-SERVER}:8092/jwireless",
#      "smsGateway.host" => "http://localhost:8111/service/messaging",
#      "system.connectivity.microservice.url" => "http://localhost:8111/service/connectivity",
      "email.from" => "no-reply@cumulocity.com",
      "errorMessageRepresentationBuilder.includeDebug" => "false",
      "passwordReset.email.subject" => "Password reset",
      "passwordReset.token.email.template" => 'Dear Cumulocity user,\n\n\
            You or someone else entered this email address when trying to change the password of a Cumulocity portal user.\n\n\
            Please use the following link to reset your password: \n\
            {host}?token={token}&showTenant\n\n\
            If you were not expecting this email, please ignore it. \n\n\
            Kind regards,\n\
            Cumulocity support team\n',
      "passwordReset.user.not.found.email.template" => 'Hi there,\n\n\
            you or someone else entered this email address when trying to change the password of a Cumulocity Testbedportal user.\n\n\
            However, we could not find the email address in your account. Please contact the administrator of your \
            account to set your email address and password. If you are the administrator of the account,\
            please use the email address that you registered with.\n\n\
            If you were not expecting this email, please ignore it. In case of questions, please get in contact with the administrator of the Cumulocity Tesbed portal. \n\n\
            Kind regards,\n\
            The Cumulocity support team\n',
      "passwordReset.success.email.template" => 'Dear Cumulocity user,\n\n\
            Your password on {host} has been recently changed. \n\
            If you or your administrator made this change, you do not need to do anything more. \n\
            If you did not make this change, please contact your administrator.\n\n\
            Kind regards,\n\
            Your Cumulocity support team\n',
      "passwordReset.invite.template" => 'Hi there,\n\n\
            Please use the following link to reset your password: \n\
            {host}/apps/devicemanagement/index.html?token={token}\n\n\
            If you were not expecting this email, please ignore it. \n\n\
            Kind regards,\n\n\
            Your Cumulocity support team\n'
    }
  },
    "cumulocity-mongo" => {
        "installEnterprise" => true,
        "version" => "3.6",
        "initRunUser" => "mongod",
        "initRunGroup" => "mongod",
        #'members-check' => false,
        #"installEnterprise" => true, # migration change
        "wiredtiger-cache" => 6,
        "sharedkey-content" => "0jPuSN0IWMZ5JISJFkydzD/teH2EEobpkA1eRAEAkSVRJY+pXYuyA4TaAjkWbRe8\nb6GQLZK9wW1ePp/1FAK+zmY1t7cXBPzkK9P+kh2HuQNKKMo/30hDhsno42hwamVO\n3NiOACH2t35ehJlwe+9lNQHIiqcEkGPNil4QS7Ci854+rGHHuwvmlILLarjpw1Kk\ndPyzYf1dUTm+AL7+A868iHWRBHNYx4s0bjGp3qsMBn3hlI2/Ryy2VRXqKuwNCmiP\nCGk2zyZnKj/w9zmEX46yPYmVsZDDHLOi7Q4q7Klv4nPbWQbydAXf5V+WjO3Ukjcy\ndRL8+VLXm29WV8lU1tSYkkddgoYgrdQyZvrqbSfuTxzNhQ4sKUtxoPRziQ4psffw\njHC05W6SSK+y5S9mtAC8mU/7hXKkDmtpoIZHCjYOJ5NM8h1zsjLZRCvoH0cDueEF\nz5mZgzfELxdNe8uOhTkcPKDK1fjEMeW8IxyZXjiHlP8G924wBJ+Vsf1qLz6oXkwm\nFuGaDzAgoZEKhtxa9yK7ESuu/aEZj3TLte6t2MXSOlavJxYPra56/NMOJAv3Jvq9\nb3fCElUd8QqoDIUsFWHRRRbbkef35RWAmAzoKUhfGV7sF7Y8kejlBdBOy6vnPBfz\nqreNKp7NDjUJMW2yKZ0CkvGI7bPn1hlUxKXq3FKWWCqNamxDeJ2I0kR3KP+JRY4B\nolhh6M+UW5xv35JyrufnNYx2cSDBrVv0tbY3zCy+bgLC98oY92+WS5bc+KMHQcKr\nbVE/WHMcLTm5WdTAJ+V+d379uFspCcOJkzaf7hNbJTa2XKtpZ1Fm5a+pEtVgqX7N\nVbtNghC6gArzJFbCCT/7QVT6EQQ48OjZ9yOd5sXurg/OUo0FnQAGhIgphv89v3oU\n8xHN0xbfQbKtoy7L0EyJRsOSrOcglT0hdZe6OY3r/HQNdh24q8mRDBjTRQzgQIJf\n/2aTMasocPDxNna0Ej4RcVINpj5S",
        "mongodb.initUser" => "init-root",
#        "mongodb.initPassword" => "qy-LOtumU17"
  },
    "cumulocity-external-lb" => {
        "landing_page" => "https://manage.cumulocity.com/ui",
        "paas_default_page" => "https://$http_host/apps/$defapp/",
        "paas_public_default_page" => "https://manage.cumulocity.com/apps/dmpublic",
        "usePostgresForPaaS" => false,
        "paas_redirection" => true,
        "proxy_cache" => true,
        "useIPAddress" => true,
        "useMQTTsupport" => true,
        "useSSL" => true,
        #"force_proto_for_link_processor" => "https",
        "certificate_domain" => "us.cumulocity.com",
        "temp_chunkin" => false,
        "useKarafWebsocket" => true,
	"useLUAforSSLcerts" => true,
	"useLUAforLimits" => true,
	"useLUAforHealthCheck" => nil,
        "nginx" => {
            "real_ip_balancing" => true,
            "NGinxPort" => "openresty",
            "version" => "1.11.2.4-20.el7.centos.c8y.8.11.1"
        }
  },
     "cumulocity-ssagents" => {
        "useTags" => true,
        'lwm2m-agent' => {
          'subscriptions_fetch_delay' => 60000,
          'device-tenant_mapping_reload_delay' => 60000,
          'host_fwUpdate' => "lwm2m.us.cumulocity.com",
          'C8Y_lwm2mEventLoggingEnabled' => true,
          'leshan_cluster_tenant' => "lwm2mcreds",
          'leshan_cluster_tenant_username' => "lwm2m-user",
          'leshan_cluster_tenant_password' => "cISEta@qI10"
        }
  },
    'cumulocity-application' => {
      'vendme' => "application-vendme"
  },
    'cumulocity-filebeat' => {
      'tag-rename' => "oregon"
  },
    'cumulocity-rsyslog' => {
#      'cross-env-log-server' => "cumulocity-multinode-prod",
#      'log-server-ext-address' => "monitoring.cumulocity.com"
  }#,
#   "cumulocity-cep" => {
#       "properties" => {
#         "version" => "9.0.11-1",
#         " esperha.storage" => "/mnt/esperha-storage/"
#     },
#  }

)

#cookbook_versions(ChefConfig.cookbook_versions_for_env)