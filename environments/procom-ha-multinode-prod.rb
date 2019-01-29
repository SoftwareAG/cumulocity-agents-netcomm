name "procom-multinode-prod"

description "The ProCom/Clouver multinode environment in Frankfurt AWS"

cookbook_versions({
#'cumulocity'=>'= 8.18.0',
#'cumulocity'=>'= 9.0.11',
#'cumulocity'=>'= 9.20.1',
#'cumulocity-kubernetes'=>'= 8.18.0',
#'cumulocity-kubernetes'=>'= 9.0.11',
#'cumulocity-kubernetes'=>'= 9.20.1',
#'cumulocity-ssagents'=>'= 8.18.1'
#})

default_attributes(
 "fixhostname" => true,
 "fixhostsfile" => true,

 "elb" => {
      "name" => "production"
    }
)

override_attributes(
  "chef_client" => {
        "server_url" => "https://chef12.cumulocity.com"
  },
  "domainname" => "clouver.de",
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
    "address" => "manage.clouver.de"
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
#  "cumulocity-kubernetes" => {
#     "deployK8S4env" => "procom-multinode-prod",
#     "attachedEnvs" => ["procom-multinode-prod"],
#     "token" => "ta0d1q.byxyv9wyee5rr7we",
#     "docker-registry-image" => "cumulocity/registry:2.6.1",
#     "images-connString" => "https://K8Simages:K8S^imAgEs5000%@resources.cumulocity.com/kubernetes-images",
#     "images-version" => "8.19.32",
#     "images2install" => [ "cep" ]
#     "images2install" => [ "" ]
#  },

  "cumulocity-karaf" => {
    "version" => "8.19.32-1",
    "ssa-version" => "8.19.32-1",
    "memory_left_for_system" => "8192",
    "notification" => true,
    "oort-enabled" => true,
    "cep-server-enabled" => true,
    "openrelayIP" => "52.58.146.111",
    "CUMULOCITY_LICENCE_KEY" => "43f7542d4caabbf4dc7ee53e56c660003cc55b70240cb33dec598ea634d27973d42de7faefd3dd34143e4e70bc5bddfe5c6b6116c7365ca846f33893fddae33f"
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
      # "auth.checkBlockingFromOutside" => true,
#            "errorMessageRepresentationBuilder.includeDebug" => "false",
      "default.tenant.applications" => "administration,devicemanagement,cockpit",
      # cazatare85
      "management.admin.password" => "e4fbf7fc7018907a9ec0310876dfdbc8677206c2166caa450549c11f2c4a93e1",
      "tenant.admin.password" => "e4fbf7fc7018907a9ec0310876dfdbc8677206c2166caa450549c11f2c4a93e1",
      "admin.password" => "e4fbf7fc7018907a9ec0310876dfdbc8677206c2166caa450549c11f2c4a93e1",
      # "cepServer.queue.batch.limit" => "5",
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
      "default.tenant.microservices" => "device-simulator, smartrule, cep",
      "migration.tomongo.default" => "MONGO_READ_WRITE",
      #"tenant.admin.grants.disabled" => true,
      "system.support-user.enabled" => true,
      "tenantSuspend.mail.sendtosuspended" => false,
      #"tenantSuspend.mail.additional.address" => "operations@cumulocity.com",
      "microservice.websocket.port" => 8303,
      # "device-simulator.microservice.url" => "http://${DEVICE-SIMULATOR-AGENT-SERVER}:6666",
      # "smartrule.microservice.url" => "http://127.0.0.1:8334",
      # "speechAgent.baseURL" => "${SPEECH-AGENT-SERVER}:8030",
      # "smsGateway.host" => "http://${SMS-GATEWAY-SERVER}:8688/sms-gateway",
      # "system.connectivity.microservice.url" => "http://${JWIRELESS-AGENT-SERVER}:8092/jwireless",
      #  "smsGateway.host" => "http://localhost:8111/service/messaging",
      #  "system.connectivity.microservice.url" => "http://localhost:8111/service/connectivity",
      "email.from" => "no-reply@clouver.de",
      "errorMessageRepresentationBuilder.includeDebug" => "false",
      "passwordReset.email.subject" => "Password reset",
      "passwordReset.token.email.template" => 'Dear Clouver IoT user,\n\n\
            You or someone else entered this email address when trying to change the password of a Clouver portal portal user.\n\n\
            Please use the following link to reset your password: \n\
            {host}?token={token}&showTenant\n\n\
            If you were not expecting this email, please ignore it. \n\n\
            Kind regards,\n\
            Your Clouver IoT support team\n',
      "passwordReset.user.not.found.email.template" => 'Hi there,\n\n\
            you or someone else entered this email address when trying to change the password of a Clouver portal user.\n\n\
            However, we could not find the email address in your account. Please contact the administrator of your \
            account to set your email address and password. If you are the administrator of the account,\
            please use the email address that you registered with.\n\n\
            If you were not expecting this email, please ignore it. In case of questions, please get in contact with the administrator of the Clouver IoT portal. \n\n\
            Kind regards,\n\
            Your Clouver IoT support team\n',
      "passwordReset.success.email.template" => 'Dear Clouver IoT portal user,\n\n\
            Your password on {host} has been recently changed. \n\
            If you or your administrator made this change, you do not need to do anything more. \n\
            If you did not make this change, please contact your administrator.\n\n\
            Kind regards,\n\
            Your Clouver portal support team\n',
      "passwordReset.invite.template" => 'Hi there,\n\n\
            Please use the following link to reset your password: \n\
            {host}/apps/devicemanagement/index.html?token={token}\n\n\
            If you were not expecting this email, please ignore it. \n\n\
            Kind regards,\n\n\
            Your Clouver portal support team\n'
    }
  },
    "cumulocity-mongo" => {
        #"installEnterprise" => true,
        "version" => "3.6",
        "initRunUser" => "mongod",
        "initRunGroup" => "mongod",
        #'members-check' => false,
        "wiredtiger-cache" => 2,
        "sharedkey-content" => "XjiyHevwdnRRF8mPxIRcYTeDbBAaN9yxLm5Cn0NxyjER7KD0c9zSalPo3hDRJEzM\nuKJRQr6pLrAzapFmic0zjZewgsMUNWA3RH5DzsDYkfhwwnuQat4HOGHTHAR7P61m\nSrSHcMNPGfggtu5RAvjd5cMKSsy5Q7/dtd4Frnqq99GoUyy9RjLfe4Yz6c+4zxkc\n4MsSNN6SSdKjJm6YJqXVVNtJ5NFg4QRkKxbhGQ0VH154hMEfpSr5uxxabbprSCu3\nZW5XE/xuSpeYxHA9yI4811JjI6xC81egViIfovIUrrGQAlXhHxlJM1wTFRrOTad6\n3J0XBwTFOwENVM31w+BSkRrP8DKzI+x3yl6kACZwFziTfr1uPeO9qlQtmU3a1NXd\nbwDPpqzxsF6F2REbH5GF7JTpxAFcWkIyO5Jx0iZjhjM3rN5DqUcaL5Wj5K7TvAM4\nEsL+7mzx5Bx/IiW1htbPX8AE954QDL9k2UhiiV+/oCMZ8pHGsS3M6Ef1ZFxJMizQ\ncNkNQAlI1u2OOM+eqUNzg28DAiYXMBl97N1OEqWWEXXdYphaygvS/jydq6pmXwK3\nYwgnMpDcnHniOK5x3/2VO4tBn5wyMiC8WRtqPZsarC1yT4U/woaQUM1ufRDF0PQf\nBCGW7nZRP8N3ryGSXoAXY6IiwBwFcih2X7jEnBACcsfrqdNgRzOvTNpaCyBlGUNL\nbUrRFcEIRde0UyuxmyOg+NOGHUg/EFO/q2TBZhZwamlwffTSU7esxCbo3iEwT4Wl\nprGRB88QJZimeZYbndbfsb2MDFFqLvXGgiA3gvFJJO08JutcmOm9vP2i2M5PgZMh\nj+OOd3F140aoz9jDHwC3TF6NivHtBtcv4pUBALnmJspDcyN+sxYSV4CBYWZQb5wb\nI3+cWNASzybaYCI/aEf0rJAMe8lXsCHtQh+XO71926cXtxedGs3bDap3KBCH2TfA\npXRmDR/gZi/efrmAA5quJQ+/tUkq",
        "mongodb.initUser" => "init-root",
  },
    "cumulocity-external-lb" => {
        "landing_page" => "https://clouver.de/apps/devicemanagement",
        "paas_default_page" => "https://$http_host/apps/$defapp/",
        "paas_public_default_page" => "https:///apps/dmpublic",
        "usePostgresForPaaS" => false,
        "paas_redirection" => true,
        "proxy_cache" => true,
        "useIPAddress" => true,
        "useMQTTsupport" => true,
        "useSSL" => true,
        #"force_proto_for_link_processor" => "https",
        "certificate_domain" => "clouver.de",
        "temp_chunkin" => false,
        "useKarafWebsocket" => true,
	"useLUAforSSLcerts" => true,
	"useLUAforLimits" => true,
	"useLUAforHealthCheck" => nil,
        "nginx" => {
            #"real_ip_balancing" => true,
            "NGinxPort" => "openresty",
            "version" => "1.11.2.4-20.el7.centos.c8y.8.11.1"
        }
  },
     "cumulocity-ssagents" => {
        "useTags" => true,
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

)

#cookbook_versions(ChefConfig.cookbook_versions_for_env)
