name "telstra-testbed-el7-nonprod"

description "The Telstra Testbed CentOS 7 environment in Frankfurt"

cookbook_versions({
'cumulocity'=>'= 0.6.0',
'cumulocity-kubernetes'=>'= 0.4.0',
'cumulocity-ssagents'=>'= 0.4.0'
})

default_attributes(
 "elb" => {
      "name" => "production"
    }
)
override_attributes(
  "chef_client" => {
        "server_url" => "https://chef12.cumulocity.com"
  },
  "domainname" => "telstra.c8y.io",
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
    "address" => "telstra.c8y.io"
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
     "deployK8S4env" => "telstra-testbed-el7-nonprod",
     "attachedEnvs" => ["telstra-testbed-el7-nonprod"],
     "token" => "1e3145.2ff901841c48af2e",
     "images-connString" => "https://K8Simages:K8S^imAgEs5000%@resources.cumulocity.com/kubernetes-images",
     "images-version" => "8.19.0",
     "images2install" => [ "cep" ]
  },
  "cumulocity-GUI" => {
    "connString" => "https://C8YWebApps:dkieW^s99l0@resources.cumulocity.com/targets/telstra/2a299258977c",
    "version" => '8.19.4'
  },
  "cumulocity-karaf" => {
    ## "version" => "8.3.14-1",
    "version" => "8.19.5-1",
    "memory_left_for_system" => "2048",
    "notification" => true,
    "oort-enabled" => false,
    "cep-server-enabled" => true,
    "CUMULOCITY_LICENCE_KEY" => "f31412e2865d7d9322e86f652e25823d1a00e111fb5705f2c5a6fd40d40161e6fae6f413c73069e3e1eacafe94af465bad0aeb605c621e8fa098c52797804c21"
  },
  "cumulocity-core" => {
    "properties" => {
      "contextService.rdbmsURL" => "jdbc:postgresql://localhost",
      "contextService.rdbmsDriver" => "org.postgresql.Driver",
      "contextService.rdbmsUser" => "postgres",
#      "contextService.rdbmsPassword" => "tel1506STRA",
      #"smsGateway.host" => "http://10.17.23.100:8688/sms-gateway",
      "mongodb.user" => "c8y-root",
#      "mongodb.password" => "tel1506STRA",
      "mongodb.admindb" => "admin",
      "contextService.tenantManagementDB" => "management",
      "cumulocity.environment" => "PRODUCTION",
      "auth.checkBlockingFromOutside" => false,
      "errorMessageRepresentationBuilder.includeDebug" => "false",
      "default.tenant.applications" => "administration,devicemanagement,cockpit",
      "management.admin.password" => "6fc21e5288d514735fee36df931c4cdab6d709ce7995aa1b53b49853c4a2893b",
      "tenant.admin.password" => "6fc21e5288d514735fee36df931c4cdab6d709ce7995aa1b53b49853c4a2893b",
      "admin.password" => "6fc21e5288d514735fee36df931c4cdab6d709ce7995aa1b53b49853c4a2893b",
      "system.two-factor-authentication.enabled" => true,
      "system.two-factor-authentication.enforced.group" => "admins",
      "system.two-factor-authentication.host" => "http://127.0.0.1:8688/sms-gateway",
      "system.two-factor-authentication.senderAddress" => "+61418368753",
      "system.two-factor-authentication.senderName" => "Telstra IoT",
      "system.two-factor-authentication.logout-on-browser-termination" => true,
      "system.two-factor-authentication.max.inactive" => "15",
      "system.two-factor-authentication.provider" => "telstra",
      #"system.two-factor-authentication.telstra.baseUrl" => "https://m1free.rcs.msg.telstra.com/messaging/v1/sms/outbound/acr%3Acumulocity/requests",             
      "system.two-factor-authentication.telstra.baseUrl" => "https://free.rcs.telstra.com/messaging/v1/sms/outbound/acr%3Acumulocity/requests",             
      "system.two-factor-authentication.telstra.username" => "cumulocity",                                                                                        
      "system.two-factor-authentication.telstra.password" => "xBg5Wa8M",                                                                                          
      "smsGateway.host" => "http://127.0.0.1:8688/sms-gateway",
      "default.tenant.microservices" => "device-simulator, smartrule",
      "tenant.admin.grants.disabled" => true,
      "system.support-user.enabled" => true, 
      "tenantSuspend.mail.sendtosuspended" => false,
      "tenantSuspend.mail.additional.address" => "operations@cumulocity.com",
      "microservice.websocket.port" => 8303,
      "device-simulator.microservice.url" => "http://${DEVICE-SIMULATOR-AGENT-SERVER}:6666",
      "smartrule.microservice.url" => "http://10.17.23.20:8334",
      "email.from" => "no-reply@telstra.c8y.io",
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
  "cumulocity-ssagents" => {
        "useTags" => true,
        "ssAgentsIP" => "telstra-testbed-el7-core",
           },

    "cumulocity-mongo" => {
	"sharedkey-content" => "aFd8w+psznnJMULj6Vtr6Jc1pPg+ALVMAM01eD3zUzCB9VTHKOWFFp26qVNkmle5\nmLM45Igfe2mGsloyHYgSJDOe8yFPQD5CVGQhczel6NonN+5eTfn63PerKYADLVoG\nI1l7PhJoiLrqgJpSxtZAN8TidX9g37GXHiJ2ND8pJMs0FE0MS2cWLBljbJJy61ie\nRrXk2X6lb/8Cm8SobOxngZ61P/63pb6NyjRh2SkDFIysqpdaT4zIafzA4aZVRUlr\nyfID8JWSkqYYY6uMDDrqU1AZcbqMYBfCRH6YjLPfrTi6LlpRKV8sQhsAyYNfOYOn\n0tgZEeMUxTVtw3nBqrUYXBDDiO1iq+eQBVF/lY5lX1GRn/J/8Ih/N9l2bhiLjBEE\nZ3+KT3imQw+yYC2jVyS81GUyXwwoTWdYwGkrh4aszhwxpieh2kx/7JX1Ch/n9VmZ\n0VFeRCmA7Gna+BeJtVtYSFC11zf5Jb/NN5nl/genzTdPGQGTLqGcaUFbX3a4rtJh\nZnAn8FJBQl9PUgjPhWzdQDIGdC+Q3oB02nfYkLbcBFXtaO4peqAsBfr2+CBAT661\negPlB9mGr8lIRjJG28lwzIB3xhlYiFPTMXobtt40yF2omaz1HryjONopPLV2lk0l\nFL+vuI6FVhNHEltXPbIfNCiu8SCEHhIe1zmDxeyx/aXydsU0aOdm9YVhLs5XKxcr\n7JOaPtUKNx4atuocsl7z/LGo3Qo72Rnh/84kv7NL0P7DxzGOmmernvI/WMcK4IJ0\nWrrMji+gBvlyTcXV2BXsG8Bm9sedXWb4cREKVwvwrKxU7htUXyHwLKd4szfshUlp\nONNZNhgBVZWo70hIGldBNZ0bc7C7mmRm3cwK1O14eEP675IkHBz/b8uxCxbs3mlx\n3amMlzEspZG+VmXC/8cXZFy9JmjVEBoH2VTHciHbt/F+qs4bvlYvNh1mQ0Tww1oV\n+7zN5rQiC44MQ/ZB6/KoAqC/IzUz",
        "mongodb.initUser" => "init-root",
        "mongodb.initPassword" => "tel1506STRA"
  },
    "cumulocity-external-lb" => {
	"landing_page" => "https://telstra.c8y.io/apps/devicemanagement",
	"paas_default_page" => "https://$http_host/apps/$defapp/",
	"paas_public_default_page" => "https:///apps/dmpublic",
	"usePostgresForPaaS" => false,
	"paas_redirection" => true,
	"proxy_cache" => true,
	"useIPAddress" => true,
	"useMQTTsupport" => true,
 	"useKarafWebsocket" => true,
        "useSSL" => false,
        "force_proto_for_link_processor" => "https",
	"certificate_domain" => "acme.com",
	"temp_chunkin" => false,
	"nginx" => {
            "NGinxPort" => "openresty",
	    "version" => "1.11.2.4-20.el7.centos.c8y.8.11.1",
	    "real_ip_balancing" => "true"
	}
  },
    'cumulocity-rsyslog' => {
      'cross-env-log-server' => "cumulocity-multinode-prod",
      'log-server-ext-address' => "monitoring.cumulocity.com"
  },
   "cumulocity-cep" => {
       "properties" => {
         "C8Y.baseURL" => "http://telstra-testbed-el7-lb:8111",
         " esperha.storage" => "/mnt/esperha-storage/"
     },
  } 

)


