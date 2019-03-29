name "cumulocity-trial-prod"

description "The Trial production multinode environment in Frankfurt"

cookbook_versions({
'cumulocity'=>'= 9.20.3',
'cumulocity-kubernetes'=>'= 9.20.3',
'cumulocity-ssagents'=>'= 9.20.3',
'cumulocity-monitoring-agent'=>'= 9.20.3'
})

default_attributes(
 "fixhostname" => false,
 "fixhostsfile" => false,
 "elb" => {
      "name" => "production"
    }
)
override_attributes(
  "chef_client" => {
        "server_url" => "https://chef12.cumulocity.com"
  },
  "domainname" => "eu-latest.cumulocity.com",
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
    "address" => "eu-latest.cumulocity.com"
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
     "deployK8S4env" => "cumulocity-trial-prod",
     "attachedEnvs" => ["cumulocity-trial-prod"],
     "token" => "xydlz5.m8qoxddellllq7hc",
     "docker-registry-image" => "cumulocity/registry:2.6.1",
     "images-connString" => "https://K8Simages:K8S^imAgEs5000%@resources.cumulocity.com/kubernetes-images",
     "images-version" => "9.25.1",
     "images2install" => [ "" ]
  },
  "cumulocity-karaf" => {
#    "version" => "9.20.4-1",
#    "version" => "9.24.1-1",
    "version" => "9.25.1-1",
    "ssa-version" => "9.25.1-1",
    "memory_left_for_system" => "8192",
    "management-access" => [ "172.31.10.100","172.31.10.104","54.247.122.134","100.64.231.0/24", "100.64.232.0/24", "18.185.5.234" ],
    "notification" => true,
    "oort-enabled" => true,
    "cep-server-enabled" => true,
    "revDNSname" => "cepfra.cumulocity.com",
    "openrelayIP" => "52.58.146.111",
    "CUMULOCITY_LICENCE_KEY" => "93fda333090bb31eff25b81bb28cbef784722defb7719620e22883df1c7cdfb840cc99d31e464e44e0f94bd46d643f76d7f3a734ba6aebb4df3091b2e21c1430
"
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
      "management.admin.password" => "f462bd0055dd42beb7550caae2bc272d77117e80bbef62a170932272c29450bf", # DoeQu?aeNgi2
      "tenant.admin.password" => "f462bd0055dd42beb7550caae2bc272d77117e80bbef62a170932272c29450bf", # DoeQu?aeNgi2
      "admin.password" => "f462bd0055dd42beb7550caae2bc272d77117e80bbef62a170932272c29450bf", # DoeQu?aeNgi2
      "sysadmin.password" => "",
      "cepServer.queue.batch.limit" => "5",
      "cometd.heartbeat.minutes" => "3",
      "default.tenant.microservices" => "device-simulator, jwireless, sms-gateway, cepi, smartrule",
      "migration.tomongo.default" => "MONGO_READ_WRITE",
      "system.support-user.enabled" => true,
      "tenantSuspend.mail.sendtosuspended" => false,
      "microservice.websocket.port" => 8303,
      "speechAgent.baseURL" => "${SPEECH-AGENT-SERVER}:8030",
      "smsGateway.host" => "http://${SMS-GATEWAY-SERVER}:8688/sms-gateway",
#      "system.connectivity.microservice.url" => "http://${JWIRELESS-AGENT-SERVER}:8092/jwireless",
#      "system.connectivity.microservice.url" => "http://${SSLMANAGEMENT-AGENT-SERVER}:8314/sslmanagement",
#      "system.connectivity.microservice.url" => "http://${LWM2M-AGENT}:8068/lwm2m-agent",
      "email.from" => "no-reply@eu-latest.cumulocity.com",
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
        "wiredtiger-cache" => 6,
        "sharedkey-content" => "yOtaIt35VWqhH+S/OCZLh+EpgmFA7sKEo96ZMHHCcaQ+2GY4i5UXRaDQJJjcW6c0\nobFSAcYgjVED0252QqZZIP5LziQWL438V/BfNi1y07GIR7Hi6GZ4/0njlL1s4DE4\nU2ohnCdSykIzupXz/liYKJyUaIvT2boRCKRsXtbxhhhuy3CqHAmYVE6IYxlyDOP9\nmag+sYq3BtGhXeLS7XmBd/H9TfYq2YpAqSk+ZAS80E4AMfYEzFNYHv/wRVftkZL8\nBHEqR3dACbkwteRuFd7Gzh3mCVO1C0dXv2cm4u1sixqUCBsPFx/NMg5OkpSUoYwB\n0enfsMuf0vkj3VX75wbbeX9qt5ShdoAkVpYA/9iPEsa9+o+Feuc06V4tTFjmOIES\n/KCBGzg9zwMQyebZFWKqZDF1o3vkmyJJ4VPx34+H33J9wOhT9uPSOwTNkOyHBKIA\nTx4yyUpOL7CqTQTuZX+na7pFd4q/8KMZRBp/2y1oTuvhXzES898s6mxJz1KgiwPg\nlng1a40ixshdGMwwufepb5jlJ3cGRl0E1SpbnHeXKbvRraMi26VnfzJYVK0klW/w\nwsz2muu13bbStRfxkgPCisqFV3LayMfLoF9EXLdN+CpyAiiKq1I5dt2FhJRHqGDE\nuxuTa25dSiR9qVn9oGkdqSy20m5peYhbf/A6m1FDwowxf8FH/hR3hsAxVeTTsgdp\nOlm5Wfjk3k/JSqaXTvekcQB3Mzwn2xOhvfmyy1nKdEjO+rDdOXknYYmX7CkKdqFO\ngQ/TB6j4mGKc0GkbxIuGBCpC4Vxxp03F3QI3PuQVjXz6dn59hGndrKvU6Z29UBuk\n23nIwQFES6ot5VR/bnDifTrAAdSm1xPyKZl7ZzWJjCfVtMEQyVB+OzD5cCUkbCfA\nIExPH7mMEu5by4blo/WAhFi09Grq/hXwvdTxaW4GEqJXcE1+tVRH4APd1dM8RsZY\nJOhczUs39KVpKtooVrTb37Z6PJfo",
        "mongodb.initUser" => "init-root",
  },
    "cumulocity-external-lb" => {
        "landing_page" => "https://manage.eu-latest.cumulocity.com/ui",
        "paas_default_page" => "https://$http_host/apps/$defapp/",
        "paas_public_default_page" => "https://manage.eu-latest.cumulocity.com/apps/dmpublic",
        "usePostgresForPaaS" => false,
        "paas_redirection" => true,
        "proxy_cache" => true,
        "useIPAddress" => true,
        "useMQTTsupport" => true,
        "useSSL" => true,
        "certificate_domain" => "eu-latest.cumulocity.com",
#        "certificate_domain" => "cumulocity.com",
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
#          'host_fwUpdate' => "lwm2m-server2.eu-latest.cumulocity.com",
          'host_fwUpdate' => "3.120.170.138",
          'C8Y_lwm2mEventLoggingEnabled' => true,
          'leshan_cluster_tenant' => "management",
          'leshan_cluster_tenant_username' => "lwm2m-user",
          'leshan_cluster_tenant_password' => "zaeVee1oojie4ya"
        }
  },
    'cumulocity-application' => {
      'vendme' => "application-vendme"
  },
    'cumulocity-rsyslog' => {
#      'cross-env-log-server' => "cumulocity-multinode-prod",
#      'log-server-ext-address' => "monitoring.cumulocity.com"
  },
   "cumulocity-cep" => {
       "properties" => {
         "version" => "9.0.11-1",
         " esperha.storage" => "/mnt/esperha-storage/"
     },
  },

  "cumulocity-filebeat" => {
        "ssl-output" => true,
        "log-collectors" => "logging.monitor.c8y.io:6155",
	"output-to-file" => false,
	"output-file-path" => "/var/log/filebeat/json",
	"tag-rename" => nil,
	"env-prefix-rename" => false,
	"env-name-swap" => true,
}, 

  'monitoring-agent' => {
    'autoRegistration' => {
      'enable' => true,
      'groupName' => 'Cumulocity Trial FRA'
    }
  }
  #'cumulocity-opsmanager' => {
    # 'mmsGroupId' => '5c120f8cfd6a9006cb99cba8',
    # 'mmsApiKey' => '5c2b73e14352d86e483b1175a985498786f16e2e76ca3ac946377a28',
    # 'mmsBaseUrl' => 'https://opsmanager.cumulocity.com'
  #}

)

#cookbook_versions(ChefConfig.cookbook_versions_for_env)
