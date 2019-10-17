name "turkcell-multinode-dev"

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
  "domainname" => "iottest.turkcell.com.tr",
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
     "deployK8S4env" => "turkcell-multinode-dev",
     "attachedEnvs" => ["turkcell-multinode-dev"],
     "token" => "of3fov.cc5ebd5grupiunxh",
     "images-connString" => "https://K8Simages:K8S^imAgEs5000%@resources.cumulocity.com/kubernetes-images",
     "images-version" => "9.20.7",
     #"images2install" => [ "cep","cep-small" ]
     "images2install" => [ ]
  },
  "cumulocity-karaf" => {
    "version" => "9.20.7-1",
    "memory_left_for_system" => "10240",
    "notification" => true,
    "oort-enabled" => true,
    "cep-server-enabled" => true,
    "CUMULOCITY_LICENCE_KEY" => "c80e5e24a8a65818a764c3c537b06013ea6f9fb609829a048f8c4946ca83ad7f02c112866859f49de0c1f57c2f44a5944d297f6705b518ed5944f0180e0b9ebd"
  },
  "cumulocity-core" => {
    "properties" => {
      "system.authentication.badRequestCounter" => "6",
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
        "sharedkey-content" => "e2bFX7LmqEPbcFUPNHHPFVDvQHX9zozF/Fbx5Rw3fkOVK1P3qT82A2DSf02JVOGp\nN91BYCx4p7DgChjBqWTFOCkbgxdfWJrhdyBZdYPW9bnuGER+W7X3uXPnbik54vhS\nl0k+o0ZySCkIMMVNoxgzqSmTid2yzQggIvfE4vMqAo+6PEAfoT5AHIU4JMEwABKS\nXX0KdFWb4A3GqLTHhLmR/AXyhNjivEkTGWKZsb97MN8OhaIl8k5LPJrl3FqXW9Mk\nGQZYY2uZGn8ReqHIngUNgpWa6VzG/WYT/7KP6w6OwOGr2A04Z/m0dRaj25sHzYH7\nkQxM4pJz0dQCAXkLrj7qegHK92/VOu3q/jYG162Fik2sY2W0j5uA3g2kKCfOGxj+\nUYr68qbLHul5kqZBiL0gChNMnEWCxCuiY7S2ZyhFtHWl/a+HnTMd+tQu7gHas9W2\nqHin5jZiUYYwrQttZjO9d+qVAOKHS5W3KlkWbXCp22M7xHL8oo0e4tOSw+6WWJ/c\nUZLpVNVK/+9Qls7wT7aJzDz7+0IyoK8oc/iq3+Dy9A0cLe+ddKEcpfz6nQz1wRbK\nPE+LWeMQCF0nsVszaXp0uY65uBgZxt89WlXcd2Ze1cP8Kz6gorWuxNVFqJ48YbdL\nSkqkORrT+Ytuf4mOtyGsYmDrx2MtOkrZFUJsKBDmZYrhOGV1tXQpPe1+nu/FrgR2\nQDYpK3wqFUAQH5ZQia/OijEU0QDc6JpzFRST/WCzVeQTaG2Hi9zQMqfvfEVdXDMy\ngvM3QInfGbcH/QgLtGpJNJ0xMDIGT3YToZ9xXRqVEssrKwUQqmonM7t9X4v9XeLC\nq+44a66KVlvolBI5VGWddWRmdAsxi6fQY46evlnFLB7MGTc4ZZcSLoXAkrW3t2Mp\nzVFLL67PJO4dA5jQJFgDcg9o0wfXE0JEU5yMS5G286cTpY9iOIGc/Y32q3trrdH3\nJFtP7rOM45IBKYNJ0lVIKR2Sgrt7",
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
        "certificate_domain" => "iottest.turkcell.com.tr",
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
         " esperha.storage" => "/mnt/esperha-storage/"
     },
  }

)

#cookbook_versions(ChefConfig.cookbook_versions_for_env)
