name "turkcell-multinode-prod"

description "The Turkcell production environment"

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
  "domainname" => "iot.turkcell.com.tr",
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
    "address" => "turkcell.tgc"
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
     "deployK8S4env" => "turkcell-multinode-prod",
     "attachedEnvs" => ["turkcell-multinode-prod"],
     "token" => "qylsal.5zglup0irsilelzr",
     "images-connString" => "https://K8Simages:K8S^imAgEs5000%@resources.cumulocity.com/kubernetes-images",
     "images-version" => "9.20.11",
     #"images2install" => [ "cep","cep-small" ]
     "images2install" => [ ]
  },
  "cumulocity-karaf" => {
    "version" => "9.20.11-1",
    "memory_left_for_system" => "10240",
    "notification" => true,
    "oort-enabled" => true,
    "cep-server-enabled" => true,
    ## Added management-access 13.09.2019
    ##"management-access": [ "10.0.0.0/8" ],
    "management-access": [ "10.0.0.0/24", "172.18.53.140","172.18.53.141","172.18.53.142","172.18.53.143","172.18.53.144","172.18.53.145","172.18.53.146","172.18.53.147","172.18.53.148","172.18.53.149","172.18.53.150","10.214.75.140","10.214.75.141","10.214.75.142" ],
    "CUMULOCITY_LICENCE_KEY" => "2488097252c4f8b2f374ef15924b8c2d54067bedfc67add2f75cc5db420f4bf079c49507284df46d5c1b7c8da04d703d206f1f0a829cfe1a2d94a0b37261fa67"
  },
  "cumulocity-core" => {
    "properties" => {
      "contextService.rdbmsURL" => "jdbc:postgresql://localhost",
      "contextService.rdbmsDriver" => "org.postgresql.Driver",
      "contextService.rdbmsUser" => "postgres",
      "system.authentication.badRequestCounter" => "6",
      "mongodb.user" => "c8y-root",
      "mongodb.admindb" => "admin",
      "contextService.tenantManagementDB" => "management",
      "cumulocity.environment" => "PRODUCTION",
      ## changed to true 13092019
      "auth.checkBlockingFromOutside" => true,
#            "errorMessageRepresentationBuilder.includeDebug" => "false",
      "default.tenant.applications" => "administration,devicemanagement,cockpit,feature-microservice-hosting,feature-cep-custom-rules",
      "management.admin.password" => "9e5989767e57daa85e39256b619c7c3e356817db4a5a88f365236a29bb32257e", # shie3rah7eX8emi
      "tenant.admin.password" => "9e5989767e57daa85e39256b619c7c3e356817db4a5a88f365236a29bb32257e", # shie3rah7eX8emi
      "admin.password" => "9e5989767e57daa85e39256b619c7c3e356817db4a5a88f365236a29bb32257e", # shie3rah7eX8emi
      "sysadmin.password" => "", # leave this param empty to prevent the platform from creating sysadmin user for new tenants
      #"system.two-factor-authentication.enabled" => false,
      #"system.two-factor-authentication.enforced.group" => "admins",
      #"system.two-factor-authentication.host" => "http://${SMS-GATEWAY-SERVER}:8688/sms-gateway",
      #"system.two-factor-authentication.senderAddress" => "",
      #"system.two-factor-authentication.senderName" => "Turkcell",
      #"system.two-factor-authentication.logout-on-browser-termination" => true,
      #"system.two-factor-authentication.max.inactive" => "14",
      #"system.two-factor-authentication.provider" => "turkcell",
      #"system.two-factor-authentication.turkcell.baseUrl" => "https://m1free.rcs.msg.turkcell.com/messaging/v1/sms/outbound/acr%3Acumulocity/requests",
      #"system.two-factor-authentication.turkcell.baseUrl" => "https://free.rcs.turkcell.com/messaging/v1/sms/outbound/acr%3Acumulocity/requests",
      #"system.two-factor-authentication.turkcell.username" => "cumulocity",
      #"system.two-factor-authentication.turkcell.password" => "<smspassword>",
      "default.tenant.microservices" => "device-simulator, smartrule, cep",
      "migration.tomongo.default" => "MONGO_READ_WRITE",
      #"tenant.admin.grants.disabled" => true,
      "system.support-user.enabled" => true,
      "tenantSuspend.mail.sendtosuspended" => false,
      #"tenantSuspend.mail.additional.address" => "operations@cumulocity.com",
 #     "device-simulator.microservice.url" => "http://${DEVICE-SIMULATOR-AGENT-SERVER}:6666",
 #     "smartrule.microservice.url" => "http://127.0.0.1:8334",
      "email.from" => "no-reply@turkcell.tgc",
      "errorMessageRepresentationBuilder.includeDebug" => "false",
      "passwordReset.email.subject" => "Password reset",
      "passwordReset.token.email.template" => 'Dear Turkcell user,\n\n\
            You or someone else entered this email address when trying to change the password of a Turkcell portal user.\n\n\
            Please use the following link to reset your password: \n\
            {host}?token={token}&showTenant\n\n\
            If you were not expecting this email, please ignore it. \n\n\
            Kind regards,\n\
            Turkcell support team\n',
      "passwordReset.user.not.found.email.template" => 'Hi there,\n\n\
            you or someone else entered this email address when trying to change the password of a Turkcell portal user.\n\n\
            However, we could not find the email address in your account. Please contact the administrator of your \
            account to set your email address and password. If you are the administrator of the account,\
            please use the email address that you registered with.\n\n\
            If you were not expecting this email, please ignore it. In case of questions, please get in contact with the administrator of the Turkcell Tesbed portal. \n\n\
            Kind regards,\n\
            The Turkcell support team\n',
      "passwordReset.success.email.template" => 'Dear Turkcell user,\n\n\
            Your password on {host} has been recently changed. \n\
            If you or your administrator made this change, you do not need to do anything more. \n\
            If you did not make this change, please contact your administrator.\n\n\
            Kind regards,\n\
            Your Turkcell support team\n',
      "passwordReset.invite.template" => 'Hi there,\n\n\
            Please use the following link to reset your password: \n\
            {host}/apps/devicemanagement/index.html?token={token}\n\n\
            If you were not expecting this email, please ignore it. \n\n\
            Kind regards,\n\n\
            Your Turkcell support team\n'
    }
  },
    "cumulocity-mongo" => {
        #'members-check' => false,
        #"installEnterprise" => true, # migration change
        "wiredtiger-cache" => 2,
        "sharedkey-content" => "EWY1Yu2DbjJbb0oQ91OBEnND35WS0kTr3dU24RFbWlzvBMkJ2IUKur5yvFzS4f6O\nPy1nxbfpClvJQS7QLfMCIW49iLpu+FQS0eGrfM09M6G5ayw3MMPpsOu5rtkXuh8W\ns8zaC3bapfni7gs2qk5TplbTSJ2VsHjBTMGHX9XIxIEJ56p+kWEfhawnBMB7f3WC\n6aKNPeXf8WZ4Bc8xPkocL8G9r0OQIxpkcjEIRmbRNmmCx/+l2Ca55Xwt9t4zb1I3\nHPXvML9IWz1eTvOEOMnJ8TqeZ/5JGoLR1qIPabbAacSjHukFPVtBr/PzSuV4UcHF\n/FZStfVNkn/f50EwRxwH7SqJk8V3s1hQTIfd7sO8CTHw2dzEB/lqPf5SZJzub4+j\ntdjEsb8fbhh8KaDFJnqkaQDXqV3gpIIsTV8tfbA+QMHDZpq8ByQRYSy0GI7N8odo\nR3SdvWIdWB7pwHuVngsG2hyABigDmI7NEYHpolNkCcNWdZeFHJcTeLR89MXGyxHr\nRd9yJjA95TuVfs4Y0lzsHZo5j3d2u2gb10Kz+3JmZFQUThV/8OOi6Qj4z/GnebSJ\nCOOkiNe7i1XfPvmrM93a3Y5p+dDDp5icxaR0Gb8mCdjc25fN4U+Kr2QtKXQntgF+\n7ARJiDb3Y+BnHwhVvTkNMrP+npibrsE31eYp/TbUG1yNEfyx+XXoUhQUWLgzF7zB\nyZtJYWsVZX11pHO9bIT4glFy7zXKpM0LvVAfLPQLOERDA8ptzioGXvzSXaLflbt5\n81MXM7buws4hFUAD6693Ia4S1c4i9lVJfwLtNqZaM5Yq8BYM7R1KDczQ44iXosaD\nwXDMivf7f6g+kZFSafM9F+4ujoKDpgv1KtEUeuTLtPYmWQcBrOqpRa0XA2jf+Lx4\n8EZxWbFYajmHX0/FgC8Q4ILruYRA/LcydzQMzmxOx5+UWzfUxkZTg9BYP+0dQ9Lr\n9aeyiqVjFnunp0ixq5m+R40uuwyO",
        "mongodb.initUser" => "init-root",
  },
    "cumulocity-external-lb" => {
        "ssl_ciphers" => "ECDHE-RSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-SHA384:ECDHE-RSA-AES256-CBC-SHA:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-SHA256:ECDHE-RSA-AES128-CBC-SHA:AES256-GCM-SHA384:AES256-SHA256:AES256-SHA:AES128-GCM-SHA256:AES128-SHA256:AES128-SHA:-SSLv3:-TLSv1",
        "landing_page" => "https://turkcell.tgc/apps/devicemanagement",
        "paas_default_page" => "https://$http_host/apps/$defapp/",
        "paas_public_default_page" => "https://turkcell.tgc/apps/dmpublic",
        "usePostgresForPaaS" => false,
        "paas_redirection" => true,
        "proxy_cache" => true,
        "useIPAddress" => true,
        "useMQTTsupport" => true,
        "useSSL" => true,
        "force_proto_for_link_processor" => "https",
        "certificate_domain" => "iot.turkcell.com.tr",
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
  'monitoring-agent' => {
    'createPlatformUser' => true,
    'autoRegistration' => {
      'enable' => true,
      'groupName' => 'Turkcell Production'
    }
  },
    'cumulocity-rsyslog' => {
#      'cross-env-log-server' => "cumulocity-multinode-prod",
#      'log-server-ext-address' => "monitoring.cumulocity.com"
  },
   "cumulocity-cep" => {
       "properties" => {
         " esperha.storage" => "/mnt/esperha-storage/"
     },
  }

)

#cookbook_versions(ChefConfig.cookbook_versions_for_env)
