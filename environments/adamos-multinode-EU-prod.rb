name "adamos-multinode-prod"

description "The Adamos Production environment in Azure EU"

default_attributes(
 "elb" => {
      "name" => "production"
    }
)

override_attributes(
  "chef_client" => {
        "server_url" => "https://adamosprodeuchef.adamos.com"
  },
  "domainname" => "adamos.com",
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
    "address" => "adamos.com"
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
     "deployK8S4env" => "adamos-multinode-prod",
     "attachedEnvs" => ["adamos-multinode-prod"],
     "token" => "jtin73.ff98mjbhqiy2hjq2",
     "images-connString" => "https://K8Simages:K8S^imAgEs5000%@resources.cumulocity.com/kubernetes-images",
     "images-version" => "9.0.17",
     "images2install" => [ "" ]
#     "images2install" => [ "cep" ]
  },
  "cumulocity-karaf" => {
#    "version" => "8.19.27-1",
    "version" => "9.0.16-1",
    "memory_left_for_system" => "2048",
    "notification" => true,
    "oort-enabled" => true,
    "cep-server-enabled" => true,
    "CUMULOCITY_LICENCE_KEY" => "22df66141286ffe04b4eea3b2f02bedac6cd37c263c081d0ac0d956ae14514d97eb6abf7d0ddea466c0c279aa079ad72354cdf83a9b3d98176887fdee052ec7d",
    "openrelayIP" => "52.58.146.111",
    "openrelayPORT" => "25"
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
#     "errorMessageRepresentationBuilder.includeDebug" => "false",
      "default.tenant.applications" => "administration,devicemanagement,cockpit",
      "management.admin.password" => "40e73ab74bb78c2ab9c47f67dbf525256e2a145ff5a391434c2dd68a166c0c44", # ge#gynyjo66
      "tenant.admin.password" => "40e73ab74bb78c2ab9c47f67dbf525256e2a145ff5a391434c2dd68a166c0c44", # ge#gynyjo66
      "admin.password" => "40e73ab74bb78c2ab9c47f67dbf525256e2a145ff5a391434c2dd68a166c0c44", # ge#gynyjo66
      #"system.two-factor-authentication.enabled" => false,
      #"system.two-factor-authentication.enforced.group" => "admins",
      #"system.two-factor-authentication.host" => "http://${SMS-GATEWAY-SERVER}:8688/sms-gateway",
      #"system.two-factor-authentication.senderAddress" => "",
      #"system.two-factor-authentication.senderName" => "Adamos",
      #"system.two-factor-authentication.logout-on-browser-termination" => true,
      #"system.two-factor-authentication.max.inactive" => "14",
      #"system.two-factor-authentication.provider" => "<customer>",
      #"system.two-factor-authentication.<customer>.baseUrl" => "https://m1free.rcs.msg.<customer>.com/messaging/v1/sms/outbound/acr%3Acumulocity/requests",
      #"system.two-factor-authentication.<customer>.baseUrl" => "https://free.rcs.<customer>.com/messaging/v1/sms/outbound/acr%3Acumulocity/requests",
      #"system.two-factor-authentication.<customer>.username" => "cumulocity",
      #"system.two-factor-authentication.<customer>.password" => "xBg5Wa8M",
      "default.tenant.microservices" => "device-simulator, smartrule, cep, feature-microservice-hosting, feature-cep-custom-rules",
      "migration.tomongo.default" => "MONGO_READ_WRITE",
#      "migration.tomongo.default" => "POSTGRES_READ_WRITE",
      #"tenant.admin.grants.disabled" => true,
      "system.support-user.enabled" => true,
      "tenantSuspend.mail.sendtosuspended" => false,
      #"tenantSuspend.mail.additional.address" => "operations@cumulocity.com",
      #"device-simulator.microservice.url" => "http://10.18.7.6:6666",
      #"smartrule.microservice.url" => "http://10.18.7.6:8334",
      "email.from" => "no-reply@adamos.com",
      "errorMessageRepresentationBuilder.includeDebug" => "false",
      "passwordReset.email.subject" => "Password reset",
      "passwordReset.token.email.template" => 'Dear Adamos user,\n\n\
            You or someone else entered this email address when trying to change the password of an Adamos IoT portal user.\n\n\
            Please use the following link to reset your password: \n\
            {host}?token={token}&showTenant\n\n\
            If you were not expecting this email, please ignore it. \n\n\
            Kind regards,\n\
            Adamos IoT',
      "passwordReset.user.not.found.email.template" => 'Hi there,\n\n\
            you or someone else entered this email address when trying to change the password of an Adamos IoT portal user.\n\n\
            However, we could not find the email address in your account. Please contact the administrator of your \
            account to set your email address and password. If you are the administrator of the account,\
            please use the email address that you registered with.\n\n\
            If you were not expecting this email, please ignore it. In case of questions, please get in contact with the administrator of the Adamos IoT portal. \n\n\
            Kind regards,\n\
            The Adamos IoT support team\n',
      "passwordReset.success.email.template" => 'Dear Adamos IoT user,\n\n\
            Your password on {host} has been recently changed. \n\
            If you or your administrator made this change, you do not need to do anything more. \n\
            If you did not make this change, please contact your administrator.\n\n\
            Kind regards,\n\
            Your Adamos IoT support team\n',
      "passwordReset.invite.template" => 'Hi there,\n\n\
            Please use the following link to reset your password: \n\
            {host}/apps/devicemanagement/index.html?token={token}\n\n\
            If you were not expecting this email, please ignore it. \n\n\
            Kind regards,\n\n\
            Your Adamos IoT support team\n'
    }
  },
    "cumulocity-mongo" => {
        'initRunUser' => 'mongod',
        'initRunGroup' => 'mongod',
        #'members-check' => false,
        #"installEnterprise" => true, # migration change
        "wiredtiger-cache" => 4,
        "sharedkey-content" => "YC4ojdutpatsIWKJ/dt4P6ih62SxMg3+oNWjUxYfkm/R+XsYHyqSCVoN9/OKQhGY\n2QJxVYDikZ8AjZQlTnVV6KwJfXJtdX9VkDoNbCzN2W8ExRfB2oIKpe0Sse9yApcH\nbR0WVRBgHl/y7SZI/yz4WRQW2gblBNWSPidEe/ip6a1SQjC+rEVPBBk8yUmPWg5t\nlWBZZLkttyIUCZbG9Ycm/IbKNh79NBaWFXK4YUCTmGQBvllqQfKIv9GXiH/LGWyh\n1SPDnJNmA80AoX0h9djGJg6vb0a4VmHJcxTczNnHBQ91c43dEqDq9/q8uWfUgwFy\nE9g9EPCIsE+FwvQ0tPZ4WuqytYoi30qgZvyevPYWXS1TjWSV2ZHUXQPt5xLX0Sr1\nC98SnypIaenW8lg73EzRkdwPTqS2+Pc/vsXRqFYl/e3UE/OtllwjbEoTEbrt37Qr\n0qumi9g2pnPb0Df8K6OrKAl73gXUc+ls2/xV8BpPF0yQHNXCscjZIbREAJG8jUld\nfw8XUX7UJI171a3OMdnQW4w88zsYCGW3i0qLTYQ5RpulkEmLseT/pQIOvgd5sC+L\nh/r10JLStDAYwyz9bBFr48bqXpdvbJntLKzV9YaSn181AvqmwY0vYPQbXf2ZQSre\nqzs7hxZvnZHLMF7FnV+j2Qbl0aLIcM0DnpccuOqRkx0HtZQm++Q+GeyRFn5V+Lmb\nIyPTdbvrkAV9TpDGay7pgiB0IgCTe3navdm6+1jJcjSyrWEbxSH0FCRz94OrGsFV\nxTc5shIsdrPC14XwShb9oYY0WZCs9u/vIvr2iuz8pdMfYzRGpQsCRfuS0QQn0M7b\npt/pR588KQbCL6OZGZeabsSoQvBPGt7KLPjLEnaUDg6N6jkg13KxP0fHdWiOtoFS\neHXighHy/M9MFl9foh0INjKn9VormvAQFEMA6+MY2DoBtVuJcCK/4qXNki3yrSPG\nmD3Y3Wjj+T+q3nBKiLRe2lUrWqwN",
        "mongodb.initUser" => "init-root",
        ##"mongodb.initPassword" => "jupusawa31"
  },
    "cumulocity-external-lb" => {
        "landing_page" => "https://adamos.com/apps/devicemanagement",
        "paas_default_page" => "https://$http_host/apps/$defapp/",
        "paas_public_default_page" => "https://adamos.com/apps/dmpublic",
        "usePostgresForPaaS" => false,
        "paas_redirection" => true,
        "proxy_cache" => true,
        "useIPAddress" => true,
        "useMQTTsupport" => true,
        "useSSL" => true,
        "force_proto_for_link_processor" => "https",
        "certificate_domain" => "adamos.com",
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
	 #"version" => "8.19.13-1",
         " esperha.storage" => "/mnt/esperha-storage/"

     },
  }

#"postfix" =>    {
#        "smtp_sasl_auth_enable" => true,
#        "smtp_sasl_security_options" => "noanonymous",
#        "smtp_relay_username" => "AKIAJI6ZRJ5M4ZDRGHVQ",
#        "smtp_relay_password" => "sHKomTOYYTATA4OMoq2a3SUxAZgC9Ex2bLK4TIwjEWg"
#        }

)

#cookbook_versions(ChefConfig.cookbook_versions_for_env)
