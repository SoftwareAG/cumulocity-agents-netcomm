name "stelia-multinode-prod"

description "The Stelia production environment"

cookbook_versions({
'cumulocity'=>'= 1004.6.3',
'cumulocity-kubernetes'=>'= 1004.6.3',
'cumulocity-ssagents'=>'= 1004.6.3'
})

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
#  "chef_client" => {
#        "server_url" => "https://<url_or_ip_chef_server>"
#  },
  "domainname" => "connect.opteama.stelia.aero",
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
    "address" => "manage.connect.opteama.stelia.aero"
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
   ## Added following 6 rows on 13112019
     "docker-version": "1.13.1-102.git7f2769b.el7.centos",
     "docker" => {
       "log" => {
         "on-file" => true
       }
     },
     "deployK8S4env" => "stelia-multinode-prod",
     "attachedEnvs" => ["stelia-multinode-prod"],
     "token" => "0w5bs8.dr1a04eb40fu0chv",
     "images-connString" => "https://K8Simages:K8S^imAgEs5000%@resources.cumulocity.com/kubernetes-images",
     "images-version" => "9.0.17",
#     "images2install" => [ "cep" ]
     "images2install" => [ "" ]
  },
  "cumulocity-karaf" => {
#    "version" => "8.19.27-1",
#    "version" => "9.0.16-1",
#    "version" => "9.12.18-1",
#    "version" => "1004.0.6-1",
    "version" => "1004.6.12-1",
#    "ssa-version" => "1004.0.6-1",
    "ssa-version" => "1004.6.12-1",
    "memory_left_for_system" => "2048",
    "notification" => true,
    "oort-enabled" => true,
    "cep-server-enabled" => true,
    "openrelayIP" => "52.58.146.111",
    "CUMULOCITY_LICENCE_KEY" => "aee79821abc7fb1ec4de1c5be7117b7509f8e449d013b8bbcc0635961b5ae4fe8fa3ac182322f7a00a3bb4101af9ef6d0bcdac56412e666c12d053f9df4da055",
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
      "mongodb.user" => "c8y-root",
      "mongodb.admindb" => "admin",
      "contextService.tenantManagementDB" => "management",
      "cumulocity.environment" => "PRODUCTION",
      "auth.checkBlockingFromOutside" => false,
#            "errorMessageRepresentationBuilder.includeDebug" => "false",
      "default.tenant.applications" => "administration,devicemanagement,cockpit,feature-microservice-hosting,feature-cep-custom-rules",
      "management.admin.password" => "", # insert password
      "tenant.admin.password" => "", # insert password
      "admin.password" => "", # insert password
      #"system.two-factor-authentication.enabled" => false,
      #"system.two-factor-authentication.enforced.group" => "admins",
      #"system.two-factor-authentication.host" => "http://${SMS-GATEWAY-SERVER}:8688/sms-gateway",
      #"system.two-factor-authentication.senderAddress" => "",
      #"system.two-factor-authentication.senderName" => "Stelia",
      #"system.two-factor-authentication.logout-on-browser-termination" => true,
      #"system.two-factor-authentication.max.inactive" => "14",
      #"system.two-factor-authentication.provider" => "stelia",
      #"system.two-factor-authentication.stelia.baseUrl" => "https://m1free.rcs.msg.stelia.com/messaging/v1/sms/outbound/acr%3Acumulocity/requests",
      #"system.two-factor-authentication.stelia.baseUrl" => "https://free.rcs.stelia.com/messaging/v1/sms/outbound/acr%3Acumulocity/requests",
      #"system.two-factor-authentication.stelia.username" => "cumulocity",
      #"system.two-factor-authentication.stelia.password" => "",
      "default.tenant.microservices" => "device-simulator, smartrule, cep",
      "migration.tomongo.default" => "MONGO_READ_WRITE",
      #"tenant.admin.grants.disabled" => true,
      "system.support-user.enabled" => true,
      "tenantSuspend.mail.sendtosuspended" => false,
      #"tenantSuspend.mail.additional.address" => "operations@cumulocity.com",
#      "device-simulator.microservice.url" => "http://${DEVICE-SIMULATOR-AGENT-SERVER}:6666",
#      "smartrule.microservice.url" => "http://127.0.0.1:8334",
      "email.from" => "no-reply@connect.opteama.stelia.aero",
      "errorMessageRepresentationBuilder.includeDebug" => "false",
      "passwordReset.email.subject" => "Password reset",
      "passwordReset.token.email.template" => 'Dear Stelia user,\n\n\
            You or someone else entered this email address when trying to change the password of a Stelia portal user.\n\n\
            Please use the following link to reset your password: \n\
            {host}?token={token}&showTenant\n\n\
            If you were not expecting this email, please ignore it. \n\n\
            Kind regards,\n\
            Stelia support team\n',
      "passwordReset.user.not.found.email.template" => 'Hi there,\n\n\
            you or someone else entered this email address when trying to change the password of a Stelia portal user.\n\n\
            However, we could not find the email address in your account. Please contact the administrator of your \
            account to set your email address and password. If you are the administrator of the account,\
            please use the email address that you registered with.\n\n\
            If you were not expecting this email, please ignore it. In case of questions, please get in contact with the administrator of the Stelia portal. \n\n\
            Kind regards,\n\
            The Stelia support team\n',
      "passwordReset.success.email.template" => 'Dear Stelia user,\n\n\
            Your password on {host} has been recently changed. \n\
            If you or your administrator made this change, you do not need to do anything more. \n\
            If you did not make this change, please contact your administrator.\n\n\
            Kind regards,\n\
            Your Stelia support team\n',
      "passwordReset.invite.template" => 'Hi there,\n\n\
            Please use the following link to reset your password: \n\
            {host}/apps/devicemanagement/index.html?token={token}\n\n\
            If you were not expecting this email, please ignore it. \n\n\
            Kind regards,\n\n\
            Your Stelia support team\n'
    }
  },
    "cumulocity-mongo" => {
        'version' => '3.6',
        #'members-check' => false,
        #"installEnterprise" => true, # migration change
        "wiredtiger-cache" => 2,
        "sharedkey-content" => "AfrI06amyAnE38DoFuVcW+vslAdMMnXvYB1RFKsxP95Liss05CWJXacq3qAM66JI\nWw7FA77qO9cS/pEokgfj7PDacJrtl7MYwqIxceIaR/m5yjn78gscYm9iwxqc6aT6\nMa/YIYsW6IIaOwpvSG8ezAQkk+fyQmG6eaXifAA8XUcGspv2Y9XCNPDaaNuMeUR+\nUXsunSRz6wmi8GwRtWaMZ8fVCT5++zdsdyKAyYiQnEAVR5yUENJXgNOe5o4/IE25\njXl5uJieGMZj1B7o5VtS5EUwPLg8wagBoJJGRERF/rcpTtVaCrH/i4bijkSvMoBH\nBM9QkrdWkj3Y2Q733IpT2iDpfzrSOJJJKncMoZOyPtIfTPjt1jbn4UD+Do/pqRoR\ne1HjhkrlmmqeJAG79E8ksroy+Jz0DMXQZe7eUy8ewEOya5Q16ADm1nzC8SWF5zvY\nv/3bqAETF0MgheqVuAHw/T66YZYM7FNC+Ib0ZtD2gGKo+zjS2afHyOugCYW+dgkE\nGN4xvhXPj71YyxQM9l0hHzkO2Wes5Naf2jr9AmLBrmlY+I/87zeSRch/SGXgg+Cu\njywvgmVwsTUsOV9cldbVDxruZoK/fcIdgRja6GOcRhhp2oCPHuSWRslI3S6L3AwE\nQONW9bx0rWvo4nnLII1BO4ZZLuaY5ySozlplPo3nEnfW9AB4fDG4PekHkg/dPOFJ\n+7PJDU6xcJJHFLYAhqXWw5xCPqliReAme36LUtqlZque+EkJJsrLvs+KJE1/iP4A\nwc+ijpNSv5ExC+xoXiBDgh4Yxzj6BUYn24uydluEg+YR1l/K0CHxlY60PVVOLk8n\nvD+EiwsJmnAbOVYBHcu3hf+Qop0jjdNXSLhG6E/fjkY4Mdw8NZpjOWtbsZzpVlMn\nszeP6SwPTKDzHVqr6T5/vJYnqkAUcOzySdEr+Yj0vQYkny4nH6B+04Jed1uzY2BW\nxzSk8EdulAdxuJuJIOcvED/psy1m",
        "mongodb.initUser" => "init-root"
  },
    "cumulocity-external-lb" => {
        "landing_page" => "https://connect.opteama.stelia.aero/apps/devicemanagement",
        "paas_default_page" => "https://$http_host/apps/$defapp/",
        "paas_public_default_page" => "https://connect.opteama.stelia.aero/apps/dmpublic",
        "usePostgresForPaaS" => false,
        "paas_redirection" => true,
        "proxy_cache" => true,
        "useIPAddress" => true,
        "useMQTTsupport" => true,
        "useSSL" => true,
        "force_proto_for_link_processor" => "https",
        "certificate_domain" => "connect.opteama.stelia.aero",
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
#      'log-server-ext-address' => "monitoring.cumulocity.com",
      'log-server-ext-address' => "logging.monitor.c8y.io",
      'forward-to-graylog' => true
  },
   "cumulocity-cep" => {
       "properties" => {
         " esperha.storage" => "/mnt/esperha-storage/"
     },
  }

)

#cookbook_versions(ChefConfig.cookbook_versions_for_env)
