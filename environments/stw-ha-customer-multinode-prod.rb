name "stw-ha-customer-multinode-prod"

description "The STW production environment"

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
  "domainname" => "machines.cloud",
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
    "address" => "manage.machines.cloud"
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
     "deployK8S4env" => "stw-ha-customer-multinode-prod",
     "attachedEnvs" => ["stw-ha-customer-multinode-prod"],
     "token" => "cbqqpl.yhv40mbn2r06dept",
     "images-connString" => "https://K8Simages:K8S^imAgEs5000%@resources.cumulocity.com/kubernetes-images",
     "images-version" => "9.20.6",
     "images2install" => [ "" ]
  },
  "cumulocity-karaf" => {
#    "version" => "9.0.14-1",
##    "version" => "9.10.1-1",
    "version" => "9.20.10-1",
##    "ssa-version" => "9.8.7-1",
    "ssa-version" => "9.20.6-1",
##    "memory_left_for_system" => "2048",
    "memory_left_for_system" => "10240",
    "notification" => true,
    "oort-enabled" => true,
    "cep-server-enabled" => true,
    "openrelayIP" => "52.58.146.111",
    "CUMULOCITY_LICENCE_KEY" => "98c582e2bf87855346aa21f6c3ebb5d1ee27552cb25c7b0daee672ad9aed5eb9df51d63e992d5e0b2fef682fa70ff32d88e188f009497f78fc3c69caed772893",
    "linkTemplateProcessor.baseURL" => "https://{tenantDomain}", #CO-962
    "karaf" => {
        "memory"=> {
          "max_direct_memory" => "1024M"
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
      #"system.two-factor-authentication.senderName" => "STW",
      #"system.two-factor-authentication.logout-on-browser-termination" => true,
      #"system.two-factor-authentication.max.inactive" => "14",
      #"system.two-factor-authentication.provider" => "stw",
      #"system.two-factor-authentication.stw.baseUrl" => "https://m1free.rcs.msg.stw.com/messaging/v1/sms/outbound/acr%3Acumulocity/requests",
      #"system.two-factor-authentication.stw.baseUrl" => "https://free.rcs.stw.com/messaging/v1/sms/outbound/acr%3Acumulocity/requests",
      #"system.two-factor-authentication.stw.username" => "cumulocity",
      #"system.two-factor-authentication.stw.password" => "",
      "default.tenant.microservices" => "device-simulator, smartrule, cep",
#      "migration.tomongo.default" => "MONGO_READ_WRITE",
      "migration.tomongo.default" => "MONGO_READ_WRITE",
      #"tenant.admin.grants.disabled" => true,
      "system.support-user.enabled" => true,
      "tenantSuspend.mail.sendtosuspended" => false,
      "cepServer.queue.batch.limit" => "5",
      #"tenantSuspend.mail.additional.address" => "operations@cumulocity.com",
      "device-simulator.microservice.url" => "http://${DEVICE-SIMULATOR-AGENT-SERVER}:6666",
      "smartrule.microservice.url" => "http://127.0.0.1:8334",
      "email.from" => "no-reply@machines.cloud",
      "errorMessageRepresentationBuilder.includeDebug" => "false",
      "passwordReset.email.subject" => "Password reset",
      "passwordReset.token.email.template" => 'Dear STW user,\n\n\
            You or someone else entered this email address when trying to change the password of a STW portal user.\n\n\
            Please use the following link to reset your password: \n\
            {host}?token={token}&showTenant\n\n\
            If you were not expecting this email, please ignore it. \n\n\
            Kind regards,\n\
            STW support team\n',
      "passwordReset.user.not.found.email.template" => 'Hi there,\n\n\
            you or someone else entered this email address when trying to change the password of a STWportal user.\n\n\
            However, we could not find the email address in your account. Please contact the administrator of your \
            account to set your email address and password. If you are the administrator of the account,\
            please use the email address that you registered with.\n\n\
            If you were not expecting this email, please ignore it. In case of questions, please get in contact with the administrator of the STW Tesbed portal. \n\n\
            Kind regards,\n\
            The STW support team\n',
      "passwordReset.success.email.template" => 'Dear STW user,\n\n\
            Your password on {host} has been recently changed. \n\
            If you or your administrator made this change, you do not need to do anything more. \n\
            If you did not make this change, please contact your administrator.\n\n\
            Kind regards,\n\
            Your STW support team\n',
      "passwordReset.invite.template" => 'Hi there,\n\n\
            Please use the following link to reset your password: \n\
            {host}/apps/devicemanagement/index.html?token={token}\n\n\
            If you were not expecting this email, please ignore it. \n\n\
            Kind regards,\n\n\
            Your STW support team\n'
    }
  },
    "cumulocity-mongo" => {
        'members-check' => false,
        #"installEnterprise" => true, # migration change
        "wiredtiger-cache" => 2,
        "sharedkey-content" => "dP2KDIi+MhRlmwpc+vjXAlXhg6iE1+gX+SlfbHw0WSY440sInReWI3HDSRGAoFzn\nC1TDJqK6JHhnUdgVydPTLVI1r3NPcrlCEVydTg+vNh4vLRUqmAhMV1fH+uR9Idh7\nInpdAiAKaUrO82q6IUX3jZgNAihSM/YumrKLCIjII/56MoUgbm0oudTDhEv2E0EQ\nkpG0djgTvNsWueMvwsiVcYQ/RkyrsAL5Tek9UlNiMJxYoaOzCl8wtR44mIkG8vUR\n1cZNj5FJepbg75/3GZ4KPI1DP7n1q3XxU1DkHXXs9OeN5EVT5LQq4+LByVTWIg6Y\nMLuaEP0JF6mZ2eNYzfadfLkuGUCEHdwe5LB7gHEYO9b6czHRQDJqISbsRQxoZegf\nWo1cBEbc/yJqztwU8LxrgE6BWOADU9S/kljLbGNlANRIyXi267w1AFREY//Rjar8\nRaBtoy+AidyzGSbCcDzoqi1xCbzC7QCcGldcLDUDhjwwMPbYeZzTOjIhQpNeuVdk\niZFlRdyTTAcyNGJMPJ3ujYxcnrlI4iAUBehQOReQTMxuzVmkcjc4ClEphHeR8vst\n1qXVYGuhFtmfkR88zxF49r04PwK75imUUAHJl9UpCOXuYLfqS9GnDskvzWz/Wq50\nzbPEdYLpy0pRDViYu26oOyg+cCynTEGTYlipL9QPJEZJ3CFp7t8hXaBtIYqyg3Fl\njQujbSBl78yW7XCoBaCwunpzcSKEEcdkm3lydTjB168bMKR2RHI/2ZKHPNhy74nI\n9OKg9dYXsPRHIGCkTZK/wAnzAUOrLReRkDHTB/JMlpo/POtg042mKe1f38o+9eVj\nHdvAuoAOIrUUvSekFY2GEHFMapCvEFiiJcib9P+Y+f1s55ODj1fbqLWYOEmxU3u3\n/JNIAXVOA+eQf/qmHIZQnVpKKLRCyXXtWOKI63GQuylonDyQhogEWQCoDmhvbz+N\nxnC252Gbk6BRb7lXtvwmGMVAt2bx",
        "mongodb.initUser" => "init-root",
        "version" => "3.6"
  },
    "cumulocity-external-lb" => {
        "landing_page" => "https://machines.cloud/apps/devicemanagement",
        "paas_default_page" => "https://$http_host/apps/$defapp/",
        "paas_public_default_page" => "https://machines.cloud/apps/dmpublic",
        "usePostgresForPaaS" => false,
        "paas_redirection" => true,
        "proxy_cache" => true,
        "useIPAddress" => true,
        "useMQTTsupport" => true,
        "useSSL" => true,
        "force_proto_for_link_processor" => "https",
        "certificate_domain" => "machines.cloud",
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
    'cumulocity-ssagents' => {
        "sslmanagement" => {
          "salt" => "81643379eb0ca927",
          "password" => "3bb50705293bcba3"
        }
  },
'monitoring-agent' => {
  'autoRegistration' => {
    'enable' => true,
    'groupName' => 'STW NG',
  }
},
    'cumulocity-rsyslog' => {
#      'cross-env-log-server' => "cumulocity-multinode-prod",
#      'log-server-ext-address' => "monitoring.cumulocity.com",
#      'log-server-ext-address' => "logging.monitor.c8y.io",
#      'forward-to-graylog' => true
  },
   "cumulocity-cep" => {
       "properties" => {
         " esperha.storage" => "/mnt/esperha-storage/"
     },
  }

)

#cookbook_versions(ChefConfig.cookbook_versions_for_env)
