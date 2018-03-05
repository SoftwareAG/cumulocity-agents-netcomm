name "cumulocity-multinode-central-1-prod"

description "The production multinode environment in Frankfurt"

default_attributes(
 "fixhostname" => true,
 "fixhostsfile" => true,
# "fixhostname" => false,
# "fixhostsfile" => false,
 "elb" => {
      "name" => "production"
    }
)
override_attributes(
  "chef_client" => {
        "server_url" => "https://chef12.cumulocity.com"
  },
  "domainname" => "cumulocity.com",
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
     "deployK8S4env" => "cumulocity-multinode-central-1-prod",
     "attachedEnvs" => ["cumulocity-multinode-central-1-prod"],
     "token" => "ta0d1q.byxyv9wyee5rr7we",
     "images-connString" => "https://K8Simages:K8S^imAgEs5000%@resources.cumulocity.com/kubernetes-images",
     "images-version" => "8.19.14",
     "images2install" => [ "cep" ]
  },
  "cumulocity-karaf" => {
    "version" => "8.18.10-1",
    "ssa-version" => "8.18.5-1",
    "memory_left_for_system" => "2048",
    "management-access" => [ "172.31.10.100","172.31.10.104" ],
    "notification" => true,
    "oort-enabled" => true,
    "cep-server-enabled" => true,
    "revDNSname" => "cepfra.cumulocity.com",
    "openrelayIP" => "172.31.10.100",
    "CUMULOCITY_LICENCE_KEY" => "654176766f1252e56d6eeaa877986f0737164b0e1c6110c048237e0d406f280c27d650ededb20ed6d9f0979696d2da05270a25dc76527ce89c722952e2ab7eb6"
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
      "default.tenant.microservices" => "device-simulator, smartrule, cep",
#      "migration.tomongo.default" => "MONGO_READ_WRITE",
      "migration.tomongo.default" => "POSTGRES_READ_WRITE",
      #"tenant.admin.grants.disabled" => true,
      "system.support-user.enabled" => false, 
      "tenantSuspend.mail.sendtosuspended" => false,
      #"tenantSuspend.mail.additional.address" => "operations@cumulocity.com",
      "device-simulator.microservice.url" => "http://${DEVICE-SIMULATOR-AGENT-SERVER}:6666",
      "smartrule.microservice.url" => "http://${SMARTRULE-AGENT-SERVER-ESPER}:8334",
      "speechAgent.baseURL" => "${SPEECH-AGENT-SERVER}:8030",
      "smsGateway.host" => "http://${SMS-GATEWAY-SERVER}:8688/sms-gateway",
      "system.connectivity.microservice.url" => "http://${JWIRELESS-AGENT-SERVER}:8092/jwireless",
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
        "initRunUser" => "mongod",
        "initRunGroup" => "mongod",
        #'members-check' => false,
        #"installEnterprise" => true, # migration change
        "wiredtiger-cache" => 8,
        "sharedkey-content" => "qhdToQA1bM4iDoaCQB7Qu3nsalC5vXH1906MBhcppDLWRly0zDHIIJkiHsnQVas7\nQjmCtHPcUKd0vxPLc4TBU7dHe39/NHCEws42k3Ew84bVLD84ojLmIeUBrzkGGiqg\nTeTt0JBGrUx3rLpgfQ7N6kJaBvga3EveKbj6erc/o7mWVuoCzLfc54r9phm9Emw0\nWO+YoHZMOeY55lbrld5nApIztO36Yh3Z9LjCMHyhs58iLcSEugMmdayx67thS1UH\nhgZ9VxD1pYTmbB7wOXOkBTu5etCrX+BsX2Sqdo4XVm1xwcW8NqCACh2dkblGtVQn\n3vOQ/d+j/jzVAi6u1mSwLUVo29XwsLnrGc43QFb0+7VIJf4Xwk9PodEMDgJMeswg\nJCfdIg6EGyfMhyAPqkH7+ynRmBz008tFENjCBB3VLDjy462NyLDQA5KdBeD7swdh\nPmUMNbYb/BoIIDskhVY/bOWUbY3uT7a+HgwQcIDyFGyUWQ3HbpIwy0lebDPhbXnW\nilqGUqW03ujnTryCbVfeooTZNNLzglDfnJZfUXg6Dj7LqaJU0TUCjC1N2ffytcJF\nlqETD1Q1G/EfYqALr0TGh7AqrTmlgYKDsc88elFdz4DdxkYPZCUlTYbWB+W8t7fN\nYY0G6n2venge6b1ItiLQnpHDwRI7g6k2wsYLSMnbdt8ETYRm0+eJ1rrzf5opUYq/\n/oo5y/1PzWwbx3pu8v2oNOLbX4zBntSbWSt2sVcm/8YaFcOw+SKY7E622nCmfeuD\n+cxc14pXRVEmKmimjaT73vfvlXd/KKRxFvXd79qLoGJRLWfYNvPrBEZcCBTkNuoM\nwZDqsYws/jkIxYy5HnO7mnZjSEUJI9kwP+EaXXWSk49R3CgDv4ZT/E0JgewAf/Fd\nJk1YzbPMRVh2ixnbBOPQQOkb4bucvZ9MC/wiRCryyp6pykhG52CeYxOZlFvlJZDI\nlx2h0fvsqJZeZSOTdHrfQsMGjgw3",
        "mongodb.initUser" => "init-root",
        "mongodb.initPassword" => "edf933ds^5f"
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
        "certificate_domain" => "cumulocity.com",
        "temp_chunkin" => false,
        "useKarafWebsocket" => true,
	"useLUAforSSLcerts" => nil,
	"useLUAforLimits" => true,
	"useLUAforHealthCheck" => nil,
        "nginx" => {
            "NGinxPort" => "openresty",
             "version" => "1.11.2.4-20.el7.centos.c8y.8.11.1"
        }
  },
     "cumulocity-ssagents" => {
        "useTags" => true
  },
    'cumulocity-rsyslog' => {
#      'cross-env-log-server' => "cumulocity-multinode-prod",
#      'log-server-ext-address' => "monitoring.cumulocity.com"
  },
   "cumulocity-cep" => {
       "properties" => {
         "version" => "8.18.10-1",
         " esperha.storage" => "/mnt/esperha-storage/"
     },
  }

)

#cookbook_versions(ChefConfig.cookbook_versions_for_env)
