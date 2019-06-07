name "cumulocity-deployment-test-nonprod"
description "This is an environment only for chef's deployment testing purposes. DO NOT use it for backend/GUI testing"

cookbook_versions({
'cumulocity'=>'= 1004.0.3',
'cumulocity-kubernetes'=>'= 1004.0.3',
'cumulocity-ssagents'=>'= 1004.0.3',
'cumulocity-monitoring-agent'=>'= 1004.0.3',
'cumulocity-rsyslog'=>'= 1004.0.3',
#'cumulocity'=>'= 9.20.3',
#'cumulocity-kubernetes'=>'= 9.20.3',
#'cumulocity-ssagents'=>'= 9.20.3',
#'cumulocity-monitoring-agent'=>'= 9.20.3',
#'cumulocity-rsyslog'=>'= 9.20.3',
})

override_attributes(
  "domainname" => "chef-deployment.c8y.io",
  "useVaults" => false,
  "useProxyRegister" => false,

  "environment" => {
      "address" => "management.chef-deployment.c8y.io"
  },
  "swapfilesize" => 512,
  "skipUsersConfig" => false,
  "extra_packages" => ["mc","telnet"],
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
     "deployK8S4env" => "cumulocity-deployment-test-nonprod",
     "attachedEnvs" => ["cumulocity-deployment-test-nonprod"],
     "token" => "1e3145.2ff901841c78ad1d",
     "images-connString" => "https://K8Simages:K8S^imAgEs5000%@resources.cumulocity.com/kubernetes-images",
     "images-version" => "1004.5.0",
##     "images-version" => "9.20.8",
     "images2install" => [ "smartrule","sms-gateway","cep","cep-small","device-simulator" ],
     "monitoring" => {
       "enabled" => false,
       "dashboard-only" => nil
     },
     "docker" => {
        "log" => {
            "on-file" => true
        }
     }
  },
  "cumulocity-karaf" => {
    "CUMULOCITY_LICENCE_KEY" => "935ee00dfb58a74061cd9ec999dbda5c8936f82f9c56bc247863b00622f9a9119be7088f04efd56db66e40dc7adec14c0cf22cb6fa1be5d0539a0195513f40a8",
    "version" => "1004.5.0-1",
##    "version" => "9.20.8-1",
    "ssa-version" => "1004.4.0-1",
##    "ssa-version" => "9.20.3-1",
    "memory_left_for_system" => "2048",
    "notification" => true,
    "cep-server-enabled" => true,
    "CUMULOCITY_LICENCE_DIR" => nil,
    "management-access" => [ "0.0.0.0/0" ],
    "openrelayIP" => "172.31.15.250",
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
  "cumulocity-chaos-monkey" => {
        "server_terminations" => {
                "groups" => {
                "your-group-name" => {
                    "enabled" => true,
                    "search_query" => "role:cumulocity-mn-active-core",
                    "min_instances_running" => 1,
                    "mean_time_between_kills" => 1
                }
            }
        },
        "working_hours" => {
            "start" => 7,
            "end" => 22
        }
  },
  "cumulocity-mongo" => {
    "sharedkey-content" => "oxUyBP8EojiqPKeF/pTSwkQGQb5/Nj9K0OcbBDfJA5eAqAiADLR1AMapq8PTYWx7\npd3z5/aLcjptklZS39Ea7sqsZakrcdeOsJ6BN3F1xct9LGbsDjWtSwkphBImjvJR\nBg+ZVJdbiwEe8q85F/e47M3hE+yxZiN9gShb37Q5oOVBrl6GYMZIlWAz7u7gZp5C\nYWY5y+hp1DaR3Ime2i4mqy19aMAqVgTVgeU9Aewmb4Q3TtOrehNjXRglWJdQUdgN\n4yo5LvlW1s7eyeqrwSWVg/WjEEUFK5ZxDkUPNIRIg1sgJR2a0FsD6rwTiJoiE2cS\nq8QRPAhMFqSwpusKcZU53/FoRrqovciLAxxYqsl5w7gtr3FyCqAJpFyUqDBGNtvC\njGztVC1eg5T7SGPFbUG2CJWuaBDJ4zo2faCVuHvgLjR3KMhF7og+k5WpqrJ+TSN0\nWha9/pH3N/zS9WtVJnFmBFW0yWXRfHWqmMB0N9+rmlEtlhT29pZlXeaPiBLr94dj\nYRTxuhS/NMIuiN674ODSA/dzWRY3F+0w+z6+GeGSK0fg5hsxvm4KR6yW1OLErWXL\n9CKjIV42nZGB5SDFoth9bZSCcR/2qJaBKfcy9o2Ua8BBBK+AT3nOjjUYn+jT9WsT\nadxlTXyvKcbYv1mAJgPQkZs8vK94brgJG3a0BtFA56yVxzujnYVadyIoHHoJ2hQ4\nL36lW50ltSCtpADEtua/LmCW60FNjRu3V7+rNSJ6YO8EdTGcb1HLO3lMIqopmadk\nAXa1q1HblDfTgsxZ1QKYSVvxdSdRh8Id/wkHLaKzgG4s305+pJe7LZsFpKGkfvvf\n97hIjngs6Ck07VzWB1O3QxMDJRZuPxKoRkRbc1uqeJAwJ4MmJSc1C6epQ9uXY0rQ\noeWkPdj/ce0486piVdrI1fpCmiOIaIjkSAZ6yzFD2cgvjzdc0y5xzuzAMs0Z8QP1\nSWrl8KNltY4U8CdIwrtvdNoEcC5Q",
    "mongodb.initUser" => "init-root",
    "mongodb.initPassword" => "init-pass"
  },

  "cumulocity-GUI" => {
    "connString" => "https://C8YWebApps:dkieW^s99l0@resources.cumulocity.com/targets/cumulocity/e153c733d590",
    "version" => '1004.0.0'
##      "version" => "9.20.3"
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
      "default.tenant.microservices" => "device-simulator, smartrule, cep, tenant-sla-monitoring",
      "device-simulator.microservice.url" => "http://${DEVICE-SIMULATOR-AGENT-SERVER}:6666",
      "smartrule.microservice.url" => "http://${SMARTRULE-AGENT-SERVER-ESPER}:8334",
      "sendDashboardAgent.url" => "http://localhost:19191/report",
      "mongodb.user" => "c8y-root",
      "mongodb.admindb" => "admin",
      "mongodb.password" => "Moabit-7777^",
      "contextService.rdbmsURL" => "jdbc:postgresql://localhost",
      "contextService.rdbmsDriver" => "org.postgresql.Driver",
      "contextService.rdbmsUser" => "postgres",
      "contextService.tenantManagementDB" => "management",
      "cumulocity.environment" => "PRODUCTION",
      "auth.checkBlockingFromOutside" => "true",
      "migration.tomongo.default" => "MONGO_READ_WRITE_POSTGRES_WRITE",
      "smsGateway.host" => "http://localhost:8688/sms-gateway",
      "email.host" => "postfix.cumulocity-staging-nonprod.svc.cluster.local",
      "email.from" => "no-reply@app.domain.com",
      "errorMessageRepresentationBuilder.includeDebug" => "false",
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
    "landing_page" => "https://chef-deployment.c8y.io/apps/devicemanagement",
    "paas_default_page" => "http://$http_host/apps/$defapp",
    "paas_public_default_page" => "https://chef-deployment.c8y.io/apps/dmpublic",
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
    "useK8SDashboard" => nil,
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
