name "cumulocity-small7-nonprod"
description "The production environment"

cookbook_versions 'cumulocity' => '= 0.2.0'

override_attributes(
  "domainname" => "dev7.c8y.io",

  "environment" => {
      "address" => "management.dev7.c8y.io"
  },
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
     "deployK8S4env" => "cumulocity-staging7-nonprod",
     "attachedEnvs" => [],
     "token" => "1e3145.2ff901841c48af2e"
  },
  "cumulocity-karaf" => {
    "CUMULOCITY_LICENCE_KEY" => "3066833fb1f087c2fef23f0e562afa6ef645ee7a86275eab8396b2d91183dd42eba7b856bf6b3b6b0a7149525a99bcd74c6e18520956a887ab2aaf956665a0ae",
    "version" => "8.16.1-1",
    "ssa-version" => "8.15.2-1",
    "memory_left_for_system" => "2048",
    "notification" => true,
    "cep-server-enabled" => true,
    "CUMULOCITY_LICENCE_DIR" => nil,
    "management-access" => [ "0.0.0.0/0" ],
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
    "sharedkey-content" => "1y7LbnZkJvDgtUOHN+8L++DAABlWdLO6kA+GXR23vl5QlslmqlB6goKQmDzgeMdA\nGC38ZcPLejm2Mnvk3TF7QHlhW1OvQZFOk600/Z9qbkzIjfQLNU4RIOdWq7pTq70w\nsyIbBXAZ+ZS2AUQnObxRiToIeDxakzjuiTQbwfYz7Z2bA/hJMrKNdI//IeRl93gt\nMAV5f07l5WQQ8OcKjqYlga1J2izcVmcbd6Q0PCtp38MrmBe3iEn34FpiAgDVZp06\ncuNJDUwr2YF90KWLs53g85vfhybNchxISXMSJBFApId8cuVeZ2oRKf7HjcyrsRR6\nUxk/74MMKvsXdxG2e2pfgTywyZ5Ndk5pGKXj6TZ5QY4Qw2QHryVPyRT90xogdDtg\nA4A8iSWRBgnrtJP+qvlfBSCpdN0EqmHqGuWcqzkc4sjpO9ubQdqvBFni9X0A6mxE\nWwGH2tk6uWQU4+OPfoQkVgUCFgepFWuzWHj9TA71sn0hmDLnBZDUh3yKcEz++qKy\nchfOPrnhSPpvZI0762F5LdIp7cuAwMC4wEYSSloawzqBnCpvQ0BsFAyprhZhFDdV\nUP67nmp/q5oaXgdr3TJOTGkRgcPXRSuf4zV4nKdMdyy7HM9o24LGXiJ40b3CZGhm\nyG0tRoTRNTd6hgFQWYp8hT4EK++kf60boGhUSPxvlkbERZ/mx4kPGY1fYWkRN8Y8\nbZXDnwu+A3kqCwSTJ6tjzrtqlQ51z5rJWl14eIo2Ienfym1tquoPNMeksQroivRB\n1ZXlA3v68+nHy2HljMsLUjt8oxho3HhN1RcDXazf4b39n5nZS4wOxjvPvqSrX4bw\n/Hwh8wL2+IDfOLl1yAO6isrEXApJSTiXFt5fSbaPW6T7hCiCkNPzdS+FYLArozNE\nYrzvmkbcHfMqqTCdWDSOWV7pRqvUARRFi0CvjWh85zmt4LG7IY/GBKJvmSAfFX1O\n5OCavvQrRbnH/m1xW7NHXbeWH80K",
    "mongodb.initUser" => "init-root",
    "mongodb.initPassword" => "felix"
  },

  "cumulocity-GUI" => {
    "connString" => "https://C8YWebApps:dkieW^s99l0@resources.cumulocity.com/targets/cumulocity/e153c733d590",
    "version" => '8.16.0'
  },
  "cumulocity-ssagents" => {
    "useTags" => true
  },
  "cumulocity-core" => {
    "properties" => {
      "system.connectivity.microservice.url" => "http://127.0.0.1:8092/jwireless",
      "default.tenant.microservices" => "device-simulator, smartrule",
      "device-simulator.microservice.url" => "http://127.0.0.1:6666",
      "smartrule.microservice.url" => "http://127.0.0.1:8334",
      "sendDashboardAgent.url" => "http://localhost:19191/report",
      "mongodb.user" => "c8y-root",
      "mongodb.admindb" => "admin",
      "contextService.rdbmsURL" => "jdbc:postgresql://localhost",
      "contextService.rdbmsDriver" => "org.postgresql.Driver",
      "contextService.rdbmsUser" => "postgres",
      "contextService.tenantManagementDB" => "management",
      "cumulocity.environment" => "PRODUCTION",
      "auth.checkBlockingFromOutside" => "false",
      "smsGateway.host" => "http://localhost:8688/sms-gateway",
      "email.from" => "no-reply@app.domain.com",
      "errorMessageRepresentationBuilder.includeDebug" => "false",
      "default.tenant.applications" => "administration,devicemanagement,cockpit",
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
    "landing_page" => "https://dev7.c8y.io/apps/devicemanagement",
    "paas_default_page" => "https://$http_host/apps/devicemanagement",
    "paas_public_default_page" => "https://dev7.c8y.io/apps/dmpublic",
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
    "nginx" => {
        "version" => "1.10.1-1.el7.centos.ngx.c8y.8.15.0"
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
