name "a1-ha-pe1-prod"

description "The first 8.19 PE A1 HA production environment"

default_attributes(
 "elb" => {
      "name" => "production"
    }
)
override_attributes(
  "chef_client" => {
        "server_url" => "https://mgmt1.cum.exoat1"
  },
  "domainname" => "iot.a1.digital",
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
    "address" => "iot.a1.digital"
  },
  "java" => {
     "jdk_version" => "8"
  },
  "nagios" => {
    "users" => {
          "admin_role" => "nagios_admin",
    },
    "server" => {
        "version" => "3.4.3",
        "checksum" => "adb04a255a3bb1574840ebd4a0f2eb76"
        }
    },
  "cumulocity-kubernetes" => {
     "deployK8S4env" => "a1-ha-pe1-prod",
     "attachedEnvs" => ["a1-ha-pe1-prod"],
     "token" => "8so4lu.mapfhwrgucymfatf",
     "images-connString" => "https://K8Simages:K8S^imAgEs5000%@resources.cumulocity.com/kubernetes-images",
     "images-version" => "8.19.23",
     "images2install" => [ "cep" ],
     "heapster" => {
       "enabled" => true
     }
  },
  "cumulocity-karaf" => {
    "version" => "8.19.23-1",
    "memory_left_for_system" => "2048",
    "notification" => true,
    "oort-enabled" => true,
    "cep-server-enabled" => true,
    "ssa-version" => "8.19.5-1",
    "CUMULOCITY_LICENCE_KEY" => "e2465f796d22db1a81fdea0f16b1ffd3b5d14bb373e13a640e2123089bcaf1cacdcdac5fb63cdbb31d297998a939031d3b82ff6be54345cea7435e3a1d76dca5"
  },
  "cumulocity-core" => {
    "properties" => {
      "contextService.rdbmsURL" => "jdbc:postgresql://localhost",
      "contextService.rdbmsDriver" => "org.postgresql.Driver",
      "contextService.rdbmsUser" => "postgres",
#      "contextService.rdbmsPassword" => "1604",
#      "system.connectivity.microservice.url" => "http://185.150.9.179:8092/jwireless",
      "mongodb.user" => "c8y-root",
#      "mongodb.password" => "1604",
      "mongodb.admindb" => "admin",
      "contextService.tenantManagementDB" => "management",
      "cumulocity.environment" => "PRODUCTION",
      "auth.checkBlockingFromOutside" => false,
      ## c8yiot:18:A1
      "default.tenant.applications" => "administration,devicemanagement,cockpit,feature-microservice-hosting,feature-cep-custom-rules",
      "management.admin.password" => "7d099406f6eadcd5afe21af50cd39571ae65e916ef2eeda5825745106ceb2acc",
      "tenant.admin.password" => "7d099406f6eadcd5afe21af50cd39571ae65e916ef2eeda5825745106ceb2acc",
      "admin.password" => "7d099406f6eadcd5afe21af50cd39571ae65e916ef2eeda5825745106ceb2acc",
      "cometd.heartbeat.minutes" => "5",
      "default.tenant.microservices" => "device-simulator, smartrule, cep",
      "system.support-user.enabled" => true,
      "tenantSuspend.mail.sendtosuspended" => false,
      "tenantSuspend.mail.additional.address" => "operations@cumulocity.com",
      "device-simulator.microservice.url" => "http://185.150.9.179:6666",
      "smartrule.microservice.url" => "http://127.0.0.1:8334",
      "microservice.websocket.port" => 8303,
      # Use mongoDB only:
      "migration.tomongo.default" => "MONGO_READ_WRITE",
      "email.from" => "no-reply@iot.a1.digital",
      "errorMessageRepresentationBuilder.includeDebug" => "false",
      "passwordReset.email.subject" => "Password reset",
      "passwordReset.token.email.template" => 'Dear A1 digital IoT user,\n\n\
            You or someone else entered this email address when trying to change the password of an IoT user.\n\n\
            Please use the following link to reset your password: \n\
            {host}?token={token}&showTenant\n\n\
            If you were not expecting this email, please ignore it. \n\n\
            Kind regards,\n\
            Your A1 IoT support team\n',
      "passwordReset.user.not.found.email.template" => 'Hi there,\n\n\
            you or someone else entered this email address when trying to change the password of an A1 Iot user.\n\n\
            However, we could not find the email address in your account. Please contact the administrator of your \
            account to set your email address and password. If you are the administrator of the account,\
            please use the email address that you registered with.\n\n\
            If you were not expecting this email, please ignore it. In case of questions, please get in contact with the administrator of the A1 Iot portal. \n\n\
            Kind regards,\n\
            The A1 IoT support team\n',
      "passwordReset.success.email.template" => 'Dear A1 IoT user,\n\n\
            Your password on {host} has been recently changed. \n\
            If you or your administrator made this change, you do not need to do anything more. \n\
            If you did not make this change, please contact your administrator.\n\n\
            Kind regards,\n\
            Your A1 IoT support team\n',
      "passwordReset.invite.template" => 'Hi there,\n\n\
            Please use the following link to reset your password: \n\
            {host}/apps/devicemanagement/index.html?token={token}\n\n\
            If you were not expecting this email, please ignore it. \n\n\
            Kind regards,\n\n\
            Your A1 IoT support team\n'
    }
  },
    "cumulocity-mongo" => {
#       'members-check' => false, # default: true
#       "installEnterprise" => true, # migration change
        "wiredtiger-cache" => 8,
        "sharedkey-content" => "Yfw8LnuwR9Lrq5RB07GVIWaWlnB+I7jFiodFvVPeiEAKPbBjOxrk8t7WHZAxTN5p\nMj1BvQxU473wOMFLaglZgF+EA3m8HwxWHGFnFX7qOvgP2lb5uzjNB6nDyghrqLTK\nhGZhq7VfAat4/aAqZ9MW3VnzL9zI4EHu+q96pQU/QiM6uHYSx7Os5+VfF/iS0ZI5\nXnU9sszSXX3/wnhBdaysun0T6QGw3WvLzTV9Cy4LcDXc3aJEwvoCR+NLqiM+wTKB\nT5LIKSnERJfjtb6JnTAn+yOglNeeL3dBX8boUwi4JfoOT8d3ok1bdnDJ7eVOXHSA\nTYkGWeLIcQDccmCgLVr/RiZ3zS9oXg+Qt+TX6mUH92FXjJl9cW0ljodXbJz5oq5n\nzRk0TUCnqezJ21mIHmn+p6pHe6NT1/VlDrx/YFFDLMNUYuXJCAWxYCn9VHl6/MAD\n7F/lFMpPVOxHqtkfcdwN60m5UEqiEDYe4mDCEiPZtqMEXtNJJ2c9uI8GdqZlbZXT\nvDZP8s3sb0P4aKeSjycHmoCWv4c5bj9X5x7GgeOK5P8CaZ2+TLJ6HLD5PwAcL+bQ\nSAg2X5z1l9D6nUYs031RMhIIXRWWIjcRCx6DYFWGl2X/+XUSxPOZvsDaj4PxzuAy\nKMw5otu/+zm0ieWSz9PFs/QHvjY4FXzZZkXS8/2raOIr01t8+6pnD4da8FnNLwE+\nSR6WNB7rj7En+2CM3psELYjzaDg1PBzAK3UBcOE2azOctrzNp0qgXJtvjNXc3c6K\nEbFxuhtiTDVKSVKp4nWmYC+1ShWOwsaolzLSw87oOkTBG2NUXZP0oZ3nNC0w9LX+\nRHFFx/Xhm4a/5uGu3F/3zSs13AjEMdpTw0bpLfqBVXwcCM7UBsqLq/HrvLJqR6Gd\n97ZfZa9t89x5zRLY38N0chdFP/1EP+BXL75jmmJ7iQKVaLHOkf/8C77nEfaPF+z7\nkBJuJRoqukoZ7apOSenDwcmwX9Go",
        "mongodb.initUser" => "init-root",
        ##"mongodb.initPassword" => "prod1#1604"
        "mongodb.initPassword" => "qtr:18:IoTPE1"
  },
    "cumulocity-external-lb" => {
        "landing_page" => "https://iotsolutionbuilder.a1.qa/apps/devicemanagement",
        "paas_default_page" => "https://$http_host/apps/$defapp/",
        "paas_public_default_page" => "https://iotsolutionbuilder.a1.qa/apps/dmpublic",
        "usePostgresForPaaS" => false,
        "paas_redirection" => true,
        "proxy_cache" => true,
        "useIPAddress" => true,
        "useMQTTsupport" => true,
        "useKarafWebsocket" => true,
        "useSSL" => true,
        ##"certificate_domain" => "acme.com",
        "certificate_domain" => "cumulocity.com",
        "temp_chunkin" => false,
	"useLUAforSSLcerts" => nil,
	"useLUAforLimits" => true,
        "nginx" => {
            "NGinxPort" => "openresty",
             "version" => "1.11.2.4-20.el7.centos.c8y.8.11.1" # migration change
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

   "cumulocity-ssagents" => {
	"scriptDir" => "/root",
	"useTags" => true,
	"ssAgentsIP" => "185.150.9.179",
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
  },
  'cumulocity-opsmanager' => {
     'mmsGroupId' => '5c174fff4cfd37d6811474ae',
     'mmsApiKey' => '5c3eef3992890e62c83df304802284ca4f7ef31c089e3e59dd92f4cd',
     'mmsBaseUrl' => 'https://opsmanager.mongodb.a1.digital'
  }

)

#cookbook_versions(ChefConfig.cookbook_versions_for_env)
