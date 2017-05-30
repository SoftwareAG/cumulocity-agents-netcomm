name "production"
description "The production environment"

override_attributes(
  "domainname" => "iot.felix.com",

  'yum' => {
    'repositories' => {
      'cumulocity-testing' => {
        'enabled' => "0"
      },
      'cumulocity' => {
        'url' => "https://cumulocity:ACceP=m+2m@yum.cumulocity.com/centos/6/cumulocity/x86_64/"
       }
    }
  },

  "cumulocity-karaf" => {
    "version" => "7.47.18-1",
    "memory_left_for_system" => "2048",
    "notification" => true,
    "cep-server-enabled" => true,
      "karaf" => {
        "memory" => {
            "xms" => "1024M"
            }
        }
  },


  "cumulocity-mongo" => {
    "sharedkey-content" => "1y7LbnZkJvDgtUOHN+8L++DAABlWdLO6kA+GXR23vl5QlslmqlB6goKQmDzgeMdA\nGC38ZcPLejm2Mnvk3TF7QHlhW1OvQZFOk600/Z9qbkzIjfQLNU4RIOdWq7pTq70w\nsyIbBXAZ+ZS2AUQnObxRiToIeDxakzjuiTQbwfYz7Z2bA/hJMrKNdI//IeRl93gt\nMAV5f07l5WQQ8OcKjqYlga1J2izcVmcbd6Q0PCtp38MrmBe3iEn34FpiAgDVZp06\ncuNJDUwr2YF90KWLs53g85vfhybNchxISXMSJBFApId8cuVeZ2oRKf7HjcyrsRR6\nUxk/74MMKvsXdxG2e2pfgTywyZ5Ndk5pGKXj6TZ5QY4Qw2QHryVPyRT90xogdDtg\nA4A8iSWRBgnrtJP+qvlfBSCpdN0EqmHqGuWcqzkc4sjpO9ubQdqvBFni9X0A6mxE\nWwGH2tk6uWQU4+OPfoQkVgUCFgepFWuzWHj9TA71sn0hmDLnBZDUh3yKcEz++qKy\nchfOPrnhSPpvZI0762F5LdIp7cuAwMC4wEYSSloawzqBnCpvQ0BsFAyprhZhFDdV\nUP67nmp/q5oaXgdr3TJOTGkRgcPXRSuf4zV4nKdMdyy7HM9o24LGXiJ40b3CZGhm\nyG0tRoTRNTd6hgFQWYp8hT4EK++kf60boGhUSPxvlkbERZ/mx4kPGY1fYWkRN8Y8\nbZXDnwu+A3kqCwSTJ6tjzrtqlQ51z5rJWl14eIo2Ienfym1tquoPNMeksQroivRB\n1ZXlA3v68+nHy2HljMsLUjt8oxho3HhN1RcDXazf4b39n5nZS4wOxjvPvqSrX4bw\n/Hwh8wL2+IDfOLl1yAO6isrEXApJSTiXFt5fSbaPW6T7hCiCkNPzdS+FYLArozNE\nYrzvmkbcHfMqqTCdWDSOWV7pRqvUARRFi0CvjWh85zmt4LG7IY/GBKJvmSAfFX1O\n5OCavvQrRbnH/m1xW7NHXbeWH80K",
    "mongodb.initUser" => "init-root",
    "mongodb.initPassword" => "felix"
  },

  "cumulocity-core" => {
    "properties" => {
      "system.connectivity.microservice.url" => "http://localhost:8092/jwireless",
      "default.tenant.microservices" => "device-simulator, smartrule",
      "device-simulator.microservice.url" => "http://localhost:6666",
      "smartrule.microservice.url" => "http://localhost:8334",
      "sendDashboardAgent.url" => "http://localhost:19191/report",
      "mongodb.user" => "c8y-root",
      "mongodb.password" => "felix",
      "mongodb.admindb" => "admin",
      "contextService.rdbmsURL" => "jdbc:postgresql://localhost",
      "contextService.rdbmsDriver" => "org.postgresql.Driver",
      "contextService.rdbmsUser" => "postgres",
      "contextService.rdbmsPassword" => "felix",
      "contextService.tenantManagementDB" => "management",
      "cumulocity.environment" => "PRODUCTION",
      "auth.checkBlockingFromOutside" => "false",
      "smsGateway.host" => "http://10.17.21.5:8688/sms-gateway",
      "email.from" => "no-reply@iot.felix.com",
      "errorMessageRepresentationBuilder.includeDebug" => "false",
      "passwordReset.email.subject" => "Password reset",
      "passwordReset.token.email.template" => 'Dear iot.felix.com user,\n\n\
            You or someone else entered this email address when trying to change the password of a iot.felix.com portal user.\n\n\
            Please use the following link to reset your password: \n\
            {host}?token={token}&showTenant\n\n\
            If you were not expecting this email, please ignore it. \n\n\
            Kind regards,\n\
            iot.felix.com support team\n',
            "passwordReset.user.not.found.email.template" => 'Hi there,\n\n\
            you or someone else entered this email address when trying to change the password of a iot.felix.com portal user.\n\n\
            However, we could not find the email address in your account. Please contact the administrator of your \
            account to set your email address and password. If you are the administrator of the account,\
            please use the email address that you registered with.\n\n\
            If you were not expecting this email, please ignore it. In case of questions, please get in contact with the administrator of iot.felix.com portal. \n\n\
            Kind regards,\n\
            iot.felix.com support team\n',
            "passwordReset.success.email.template" => 'Dear iot.felix.com user,\n\n\
            Your password on {host} has been recently changed. \n\
            If you or your administrator made this change, you do not need to do anything more. \n\
            If you did not make this change, please contact your administrator.\n\n\
            Kind regards,\n\
            iot.felix.com support team\n',
            "passwordReset.invite.template" => 'Hi there,\n\n\
            Please use the following link to reset your password: \n\
            {host}/apps/devicemanagement/index.html?token={token}\n\n\
            If you were not expecting this email, please ignore it. \n\n\
            Kind regards,\n\n\
            iot.felix.com support team\n'
    }
  },

  "cumulocity-external-lb" => {
    "landing_page" => "https://iot.felix.com/apps/devicemanagement",
    "paas_default_page" => "https://$http_host/apps/devicemanagement",
    "paas_public_default_page" => "https://iot.felix.com/apps/dmpublic",
    "usePostgresForPaaS" => false,
    "paas_redirection" => true,
    "proxy_cache" => true,
    "useIPAddress" => true,
    "useSSL" => false,
    "certificate_domain" => "acme.com",
    "useMQTTsupport" => false,
    "temp_chunkin" => false
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
