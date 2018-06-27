name "cumulocity-basic-staging7-nonprod"
description "The Basic Staging 7 environment for test releases"

cookbook_versions({
'cumulocity'=>'= 0.6.0',
'cumulocity-kubernetes'=>'= 0.6.0',
'cumulocity-ssagents'=>'= 0.4.0'
})

override_attributes(
  "domainname" => "staging.c8y.io",

  "environment" => {
      "address" => "management.staging.c8y.io"
  },
  "swapfilesize" => 768,
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
     "deployK8S4env" => "cumulocity-basic-staging7-nonprod",
     "attachedEnvs" => ["cumulocity-basic-staging7-nonprod"],
     "token" => "1e3145.2ff901941c48af2e",
     "images-connString" => "https://K8Simages:K8S^imAgEs5000%@resources.cumulocity.com/kubernetes-images",
     "images-version" => "9.0.13",
     "images2install" => [ "cep" ],
     "monitoring": {
       "enabled": false
     }
  },
  "cumulocity-karaf" => {
    "CUMULOCITY_LICENCE_KEY" => "9cfda1bd57553c744d813970705747ef3c3c1f97ad669c0ff9a3c8bba40675705f458e46b46bd9710d7bc99594fe3030d7637457e94c6982ab9de77acce75806",
    "version" => "9.0.16-1",
    "ssa-version" => "8.21.0-1",
    "memory_left_for_system" => "2048",
    "notification" => true,
    "cep-server-enabled" => true,
    "CUMULOCITY_LICENCE_DIR" => nil,
    "openrelayIP" => "172.20.21.199",
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
    "sharedkey-content" => "U1nZc+UvINPiri3RRriSERbpUcJpgtvITqiwHAIN+dYcdOEGAEv2P2nKCRhRaUvB\nXy1eI/gwcFjKGFcqB/iRQ4EPL/KRJ9LKajOmbmOuMTFeYQ276d9QnnXE5Wkj10sC\nBjjSkVAeF/erOKvFdJed15Q+QXsUslwswPOxFgkUYDw7emIvkJsd6BYRS0yD8Sj3\n4ykeHs/+UK/bnPstnQfLMBq+yyLNkbY/UbKOT1gBY9A6B1MBWLlaPU9gMYO+YKMd\nauARB5WolUVjbA5Hgt0WY14tao/KYEJPig3LCrlcBsoe+W4BRHXgcIqrYNO3c2Yy\nggpNSDP2cyU8LF6uaKzr6GQqa4Gw8CwgSUbR6ylp8i/EeCrzgklHdMqclF4E7b4R\n0nAk/hZu7am2TVRIU3Lzly30jInXh9Zcd34CId8Q14VWDPh+SN3gHeCfG5yPWEsS\nm6fDTzCFK84BV/6lPG1dBxSD8qYygK+GSHzkGc2SJEmbXUz+q1xMe5dzz8g7ukTa\n0HbjAseVS1/2dtSxNgJxzerC/zOhslN6Zu2dGl3pjUuuH+GcapBfn7kmSxtOTfw8\nsfi5OejOMHEtKSiKnBNwW7vpjgq+0F9H/pbJIhiYgNlENBFkZraU1EXxNLr/jdd6\nJS3eL3/T76MYHaBe48tUfbFhaGMLG8p9EbMEqg/x5EGhs+px/np9ci6qTDaeRbFP\nP764aXLoWyL6UcDyQDl6+Oge9TJaoq5STn9TngdJendQDuZTNUcsSAlK9Tz6mb0i\nGbzFMZqpqQHBmw+3WYannksDwA++1K1zS8z0JFhNIfAG0up2cIEUHSFOwe9F4isM\n3IA/razLXXZXIFdFxFcMg9vMY3DcBvgwXwgWAs56z+tzlY5SwswVpEbMAeUBpMIB\nIvMWtkHom9Bb4vDcHBw+HxRaevHyTS40eyKBqZMFROa6B78YOwRUssMulaCBb+cA\nFOWpBFHpH884t51c7jrBLPCmjL/8",
    "mongodb.initUser" => "init-root",
    "mongodb.initPassword" => "StagBasic777^^^"
  },

  "cumulocity-GUI" => {
    "connString" => "https://C8YWebApps:dkieW^s99l0@resources.cumulocity.com/targets/cumulocity/e153c733d590",
    "version" => '9.0.16'
  },
  "cumulocity-ssagents" => {
    "useTags" => true
  },
  "cumulocity-core" => {
    "properties" => {
      "system.connectivity.microservice.url" => "http://localhost:8111/service/connectivity",
      "default.tenant.microservices" => "device-simulator, smartrule, cep",
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
      "auth.checkBlockingFromOutside" => "true",
      "migration.tomongo.default" => "MONGO_READ_WRITE",
      "smsGateway.host" => "http://localhost:8111/service/messaging",
      "email.host" => "postfix.cumulocity-basic-staging7-nonprod.svc.cluster.local",
      "email.from" => "no-reply@app.domain.com",
      "errorMessageRepresentationBuilder.includeDebug" => "false",
      "system.two-factor-authentication.enabled" => true,
      "system.two-factor-authentication.max.inactive" => "10",
      "default.tenant.applications" => "administration,devicemanagement,cockpit,feature-microservice-hosting,feature-cep-custom-rules",
      "management.admin.password" => "6fc21e5288d514735fee36df931c4cdab6d709ce7995aa1b53b49853c4a2893b",
      "admin.password" => "6fc21e5288d514735fee36df931c4cdab6d709ce7995aa1b53b49853c4a2893b",
      "sysadmin.password" => "6fc21e5288d514735fee36df931c4cdab6d709ce7995aa1b53b49853c4a2893b",
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
    "landing_page" => "https://staging.c8y.io/apps/devicemanagement",
    "paas_default_page" => "https://$http_host/apps/$defapp",
    "paas_public_default_page" => "https://staging.c8y.io/apps/dmpublic",
    "usePostgresForPaaS" => false,
    "paas_redirection" => true,
    "temp_chunkin" => false,
    "useIPAddress" => true,
    "useSSL" => true,
    "useHSTS" => false,
    "useMQTTsupport" => true,
    "useMasterForPushOperations" => false,
    "useKarafWebsocket" => true,
    "useMQTTlogs" => false,
    "proxy_cache" => true,
    "certificate_domain" => "staging.c8y.io",
    "useLUAforLimits" => true,
    "useLUAforHealthCheck" => true,
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
