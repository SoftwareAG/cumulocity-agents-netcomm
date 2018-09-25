name "cumulocity-staging-latest-nonprod"
description "The Staging 7 environment for the latest released version"

cookbook_versions({
'cumulocity'=>'= 0.6.0',
'cumulocity-kubernetes'=>'= 0.6.0',
'cumulocity-ssagents'=>'= 0.4.0'
})

override_attributes(
  "domainname" => "staging-latest.c8y.io",

  "environment" => {
      "address" => "management.staging-latest.c8y.io"
  },
  "swapfilesize" => 512,
  'yum' => {
    'repositories' => {
      'cumulocity-testing' => {
        'enabled' => "0"
      },
      'cumulocity' => {
        'url' => "https://cumulocity:ACceP=m+2m@yum.cumulocity.com/centos/7/cumulocity/x86_64/"
       }
    }
  },
  "java" => {
     "jdk_version" => "8"
  },
  "cumulocity-kubernetes" => {
     "deployK8S4env" => "cumulocity-staging-latest-nonprod",
     "attachedEnvs" => ["cumulocity-staging-latest-nonprod"],
     "token" => "1e3145.2ff901841c78af1d",
     "images-connString" => "https://K8Simages:K8S^imAgEs5000%@resources.cumulocity.com/kubernetes-images",
     "images-version" => "9.15.0",
     "images2install" => [ "cep","cep-small","device-simulator","smartrule", "apama-small", "sms-gateway-server" ],
     "monitoring" => {
       "enabled" => true,
       "dashboard-only" => true
     }
  },
  "cumulocity-chaos-monkey" => {
      "group" => {
        "my-custom-service" => {
          #"enabled" => true, # default: true
          #"chef_environment:#{node.chef_environment} AND role:cumulocity-chaos-monkey AND " + #{search_query} =>  
          "search_query" => "role:my-custom-service AND role:mn-active-core",
          #"min_instances_running" => 1 # default 2
        }
      }
  },
  "cumulocity-karaf" => {
    "CUMULOCITY_LICENCE_KEY" => "35fd2a651c866163f172274ba43a1a15632c68b49f9bcd5c96ba0b2213be257b8265ab3255d20a516a7c68dff6190a698e49f613a8e61b2e3740901d8ce44f1f",
    "version" => "9.15.0-1",
    "ssa-version" => "9.15.0-1",
    "memory_left_for_system" => "2048",
    "notification" => true,
    "cep-server-enabled" => true,
    "CUMULOCITY_LICENCE_DIR" => nil,
    "management-access" => [ "0.0.0.0/0" ],
    "openrelayIP" => "172.31.10.245",
      "karaf" => {
        "memory" => {
            "xms" => "1024M"
            }
        }
  },
  "cumulocity-cep" => {
    "properties" => {
        "esperha.storage" => "/mnt/esperha-storage"
    }
  },
  "cumulocity-mongo" => {
    "sharedkey-content" => "oxUyBP8EojiqPKeF/pTSwkQGQb5/Nj9K0OcbBDfJA5eAqAiADLR1AMapq8PTYWx7\npd3z5/aLcjptklZS39Ea7sqsZakrcdeOsJ6BN3F1xct9LGbsDjWtSwkphBImjvJR\nBg+ZVJdbiwEe8q85F/e47M3hE+yxZiN9gShb37Q5oOVBrl6GYMZIlWAz7u7gZp5C\nYWY5y+hp1DaR3Ime2i4mqy19aMAqVgTVgeU9Aewmb4Q3TtOrehNjXRglWJdQUdgN\n4yo5LvlW1s7eyeqrwSWVg/WjEEUFK5ZxDkUPNIRIg1sgJR2a0FsD6rwTiJoiE2cS\nq8QRPAhMFqSwpusKcZU53/FoRrqovciLAxxYqsl5w7gtr3FyCqAJpFyUqDBGNtvC\njGztVC1eg5T7SGPFbUG2CJWuaBDJ4zo2faCVuHvgLjR3KMhF7og+k5WpqrJ+TSN0\nWha9/pH3N/zS9WtVJnFmBFW0yWXRfHWqmMB0N9+rmlEtlhT29pZlXeaPiBLr94dj\nYRTxuhS/NMIuiN674ODSA/dzWRY3F+0w+z6+GeGSK0fg5hsxvm4KR6yW1OLErWXL\n9CKjIV42nZGB5SDFoth9bZSCcR/2qJaBKfcy9o2Ua8BBBK+AT3nOjjUYn+jT9WsT\nadxlTXyvKcbYv1mAJgPQkZs8vK94brgJG3a0BtFA56yVxzujnYVadyIoHHoJ2hQ4\nL36lW50ltSCtpADEtua/LmCW60FNjRu3V7+rNSJ6YO8EdTGcb1HLO3lMIqopmadk\nAXa1q1HblDfTgsxZ1QKYSVvxdSdRh8Id/wkHLaKzgG4s305+pJe7LZsFpKGkfvvf\n97hIjngs6Ck07VzWB1O3QxMDJRZuPxKoRkRbc1uqeJAwJ4MmJSc1C6epQ9uXY0rQ\noeWkPdj/ce0486piVdrI1fpCmiOIaIjkSAZ6yzFD2cgvjzdc0y5xzuzAMs0Z8QP1\nSWrl8KNltY4U8CdIwrtvdNoEcC5Q",
    "mongodb.initUser" => "init-root",
    "version" => "3.6"
  },

  "cumulocity-GUI" => {
    "connString" => "https://C8YWebApps:dkieW^s99l0@resources.cumulocity.com/targets/cumulocity/e153c733d590",
    "version" => '9.15.0'
  },
  "cumulocity-ssagents" => {
    "useTags" => true,
    "lwm2m-agent" => {
        "host_fwUpdate" => "34.251.8.163",
        "leshan_cluster_tenant" => "management",
        "leshan_cluster_tenant_username" => "lwm2m_user",
        "leshan_cluster_tenant_password" => "passw0rd_a"
    },
  },
  "cumulocity-core" => {
    "properties" => {
      "system.connectivity.microservice.url" => "http://${JWIRELESS-AGENT-SERVER}:8092/",
      "c8y.internal.users" => "service_cep,service_apama",
      "default.tenant.microservices" => "device-simulator, smartrule, cep, tenant-sla-monitoring, sms-gateway-server",
      "device-simulator.microservice.url" => "http://${DEVICE-SIMULATOR-AGENT-SERVER}:6666",
      "smartrule.microservice.url" => "http://${SMARTRULE-AGENT-SERVER-ESPER}:8334",
      "sendDashboardAgent.url" => "http://localhost:19191/report",
      "mongodb.user" => "c8y-root",
      "mongodb.admindb" => "admin",
      "contextService.rdbmsURL" => "jdbc:postgresql://localhost",
      "contextService.rdbmsDriver" => "org.postgresql.Driver",
      "contextService.rdbmsUser" => "postgres",
      "contextService.tenantManagementDB" => "management",
      "cumulocity.environment" => "PRODUCTION",
      "auth.checkBlockingFromOutside" => "false",
      "migration.tomongo.default" => "MONGO_READ_WRITE_POSTGRES_WRITE",
      "smsGateway.host" => "http://localhost:80/service/messaging",
      "email.host" => "postfix.cumulocity-staging-nonprod.svc.cluster.local",
      "email.from" => "no-reply@app.domain.com",
      "errorMessageRepresentationBuilder.includeDebug" => "false",
      "system.two-factor-authentication.enabled" => "true",
      "system.two-factor-authentication.enforced" => "",
      "default.tenant.applications" => "administration,devicemanagement,cockpit,feature-microservice-hosting,feature-cep-custom-rules",
      "passwordReset.email.subject" => "Password reset",
      "passwordReset.token.email.template" => 'Dear app.domain.com user,\n\n\
            You or someone else entered this email address when trying to change the password of a app.domain.com portal user.\n\n\
            Please use the following link to reset your password: \n\
            {host}?token={token}&showTenant\n\n\
            If you were not expecting this email, please ignore it. \n\n\
            Kind regards,\n\
            app.domain.com support team\n',
            "passwordReset.user.not.found.email.template" => 'Hi there,\n\n\
            you or someone else entered this email address when trying to change the password of a app.domain.com portal user.\n\n\
            However, we could not find the email address in your account. Please contact the administrator of your \
            account to set your email address and password. If you are the administrator of the account,\
            please use the email address that you registered with.\n\n\
            If you were not expecting this email, please ignore it. In case of questions, please get in contact with the administrator of app.domain.com portal. \n\n\
            Kind regards,\n\
            app.domain.com support team\n',
            "passwordReset.success.email.template" => 'Dear app.domain.com user,\n\n\
            Your password on {host} has been recently changed. \n\
            If you or your administrator made this change, you do not need to do anything more. \n\
            If you did not make this change, please contact your administrator.\n\n\
            Kind regards,\n\
            app.domain.com support team\n',
            "passwordReset.invite.template" => 'Hi there,\n\n\
            Please use the following link to reset your password: \n\
            {host}/apps/devicemanagement/index.html?token={token}\n\n\
            If you were not expecting this email, please ignore it. \n\n\
            Kind regards,\n\n\
            app.domain.com support team\n'
    }
  },

  "cumulocity-external-lb" => {
    "landing_page" => "https://staging-latest.c8y.io/apps/devicemanagement",
    "paas_default_page" => "https://$http_host/apps/$defapp",
    "paas_public_default_page" => "https://staging-latest.c8y.io/apps/dmpublic",
    "usePostgresForPaaS" => false,
    "paas_redirection" => true,
    "temp_chunkin" => false,
    "useIPAddress" => true,
    "useSSL" => true,
    "useHSTS" => false,
    "useMQTTsupport" => true,
    "useMasterForPushOperations" => false,
    "useKarafWebsocket" => true,
    "proxy_cache" => true,
    "certificate_domain" => "staging.c8y.io",
    "useLUAforLimits" => true,
    "useLUAforSSLcerts": true,
    "useLUAforHealthCheck" => true,
    "useK8SDashboard" => true,
    "nginx" => {
        "NGinxPort" => "openresty",
        "version" => "1.11.2.4-20.el7.centos.c8y.8.11.1"
    }
  },

  'vendme-platform-agent' => {
    'use-internal-proxy' => nil,
    'install-agent' => nil,
    'install-platform' => nil,
    'install-tracker' => nil
  },

  'cumulocity-rsyslog' => {
    'cross-env-log-server' => "cumulocity-multinode-prod",
    'log-server-ext-address' => "monitoring.cumulocity.com"
  }

)
