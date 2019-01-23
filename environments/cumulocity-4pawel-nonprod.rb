# frozen_string_literal: true

name 'cumulocity-4pawel-nonprod'
description 'The jenkins and cucumber test environment'

cookbook_versions(
  'cumulocity' => '~> 9.16.3',
  'cumulocity-kubernetes' => '~> 9.16.3',
  'cumulocity-ssagents' => '~> 9.16.3',
  'cumulocity-opsmanager' => '= 9.20.3'
)

default_attributes(
  'fixhostname' => false,
  'fixhostsfile' => false
)

override_attributes(
  'domainname' => '4pawel.c8y.io',

  'environment' => {
    'address' => 'management.4pawel.c8y.io'
  },
  'swapfilesize' => 0,
  'yum' => {
    'repositories' => {
      'cumulocity-testing' => {
        'enabled' => '0'
      },
      'cumulocity' => {
        'url' => 'https://cumulocity:ACceP=m+2m@yum.cumulocity.com/centos/7/cumulocity/x86_64/'
      }
    }
  },
  'java' => {
    'jdk_version' => '8'
  },
  'cumulocity-kubernetes' => {
    'deployK8S4env' => 'cumulocity-4pawel-nonprod',
    'attachedEnvs' => ['cumulocity-4pawel-nonprod'],
    'token' => '1e3145.2ff901841c48af2e',
    'images-connString' => 'https://K8Simages:K8S^imAgEs5000%@resources.cumulocity.com/kubernetes-images',
    'images-version' => '9.14.0',
    'images2install' => ['cep', 'cep-small', 'device-simulator', 'sms-gateway-server', 'smartrule'],
    'monitoring' => {
      'enabled' => false
    }
  },
  'cumulocity-karaf' => {
    'CUMULOCITY_LICENCE_KEY' => '4c09d46d909ce1629eb1ab8caa7638b3e382a3708c9b5e7cab24c96ad276ad91a9bc3c9526fe541068bbd922be5bd9d2a6ff0bad7ca63f8d1fc67a93861abd07',
    'version' => '9.14.0-1',
    'ssa-version' => '9.14.0-1',
    'memory_left_for_system' => '2048',
    'notification' => true,
    'cep-server-enabled' => true,
    'CUMULOCITY_LICENCE_DIR' => nil,
    'management-access' => ['0.0.0.0/0'],
    'openrelayIP' => '172.31.15.250',
    'karaf' => {
      'memory' => {
        'xms' => '1024M'
      }
    }
  },
  'cumulocity-cep' => {
    'properties' => {
      'esperha.storage' => '/mnt/esperha-storage'
    }
  },
  'cumulocity-mongo' => {
    'sharedkey-content' => '1y7LbnZkJvDgtUOHN+8L++DAABlWdLO6kA+GXR23vl5QlslmqlB6goKQmDzgeMdA\nGC38ZcPLejm2Mnvk3TF7QHlhW1OvQZFOk600/Z9qbkzIjfQLNU4RIOdWq7pTq70w\nsyIbBXAZ+ZS2AUQnObxRiToIeDxakzjuiTQbwfYz7Z2bA/hJMrKNdI//IeRl93gt\nMAV5f07l5WQQ8OcKjqYlga1J2izcVmcbd6Q0PCtp38MrmBe3iEn34FpiAgDVZp06\ncuNJDUwr2YF90KWLs53g85vfhybNchxISXMSJBFApId8cuVeZ2oRKf7HjcyrsRR6\nUxk/74MMKvsXdxG2e2pfgTywyZ5Ndk5pGKXj6TZ5QY4Qw2QHryVPyRT90xogdDtg\nA4A8iSWRBgnrtJP+qvlfBSCpdN0EqmHqGuWcqzkc4sjpO9ubQdqvBFni9X0A6mxE\nWwGH2tk6uWQU4+OPfoQkVgUCFgepFWuzWHj9TA71sn0hmDLnBZDUh3yKcEz++qKy\nchfOPrnhSPpvZI0762F5LdIp7cuAwMC4wEYSSloawzqBnCpvQ0BsFAyprhZhFDdV\nUP67nmp/q5oaXgdr3TJOTGkRgcPXRSuf4zV4nKdMdyy7HM9o24LGXiJ40b3CZGhm\nyG0tRoTRNTd6hgFQWYp8hT4EK++kf60boGhUSPxvlkbERZ/mx4kPGY1fYWkRN8Y8\nbZXDnwu+A3kqCwSTJ6tjzrtqlQ51z5rJWl14eIo2Ienfym1tquoPNMeksQroivRB\n1ZXlA3v68+nHy2HljMsLUjt8oxho3HhN1RcDXazf4b39n5nZS4wOxjvPvqSrX4bw\n/Hwh8wL2+IDfOLl1yAO6isrEXApJSTiXFt5fSbaPW6T7hCiCkNPzdS+FYLArozNE\nYrzvmkbcHfMqqTCdWDSOWV7pRqvUARRFi0CvjWh85zmt4LG7IY/GBKJvmSAfFX1O\n5OCavvQrRbnH/m1xW7NHXbeWH80K',
    'mongodb.initUser' => 'init-root',
    'repo-version' => '3.6',
    'blockDevice' => '/dev/nvme1n1',
    'wiredtiger-cache' => 3
  },
  'cumulocity-GUI' => {
    'connString' => 'https://C8YWebApps:dkieW^s99l0@resources.cumulocity.com/targets/cumulocity/e153c733d590',
    'version' => '9.14.0'
  },
  'cumulocity-ssagents' => {
    'useTags' => true,
    'lwm2m-agent' => {
      'host_fwUpdate' => '34.251.8.163',
      'leshan_cluster_tenant' => 'management',
      'leshan_cluster_tenant_username' => 'lwm2m_user',
      'leshan_cluster_tenant_password' => 'passw0rd_a'
    }
  },
  'cumulocity-core' => {
    'properties' => {
      'system.connectivity.microservice.url' => 'http://${JWIRELESS-AGENT-SERVER}:8092/',
      'default.tenant.microservices' => 'device-simulator, smartrule, cep, tenant-sla-monitoring',
      'device-simulator.microservice.url' => 'http://localhost:8181/service/device-simulator',
      'smartrule.microservice.url' => 'http://localhost:8181/service/smartrule',
      'sendDashboardAgent.url' => 'http://localhost:19191/report',
      'mongodb.user' => 'c8y-root',
      'mongodb.admindb' => 'admin',
      'contextService.rdbmsURL' => 'jdbc:postgresql://localhost',
      'contextService.rdbmsDriver' => 'org.postgresql.Driver',
      'contextService.rdbmsUser' => 'postgres',
      'contextService.tenantManagementDB' => 'management',
      'cumulocity.environment' => 'PRODUCTION',
      'auth.checkBlockingFromOutside' => 'false',
      'migration.tomongo.default' => 'MONGO_READ_WRITE_POSTGRES_WRITE',
      'smsGateway.host' => 'http://localhost:8181/service/messaging',
      'email.host' => 'postfix.cumulocity-staging7-nonprod.svc.cluster.local',
      'email.from' => 'no-reply@app.domain.com',
      'system.two-factor-authentication.enabled' => true,
      'system.two-factor-authentication.max.inactive' => '10',
      'system.two-factor-authentication.enforced' => 'ashutosh',
      'system.two-factor-authentication.enforced.group' => 'ashutoshTfaTest',
      'errorMessageRepresentationBuilder.includeDebug' => 'false',
      'default.tenant.applications' => 'administration,devicemanagement,cockpit,feature-microservice-hosting,feature-cep-custom-rules',
      'passwordReset.email.subject' => 'Password reset',
      'passwordReset.token.email.template' => "Dear app.domain.com user,\n\n\
    You or someone else entered this email address when trying to change the password of a app.domain.com portal user.\n\n\
    Please use the following link to reset your password: \n\
    {host}?token={token}&showTenant\n\n\
    If you were not expecting this email, please ignore it. \n\n\
    Kind regards,\n\
    app.domain.com support team\n',
    'passwordReset.user.not.found.email.template' => 'Hi there,\n\n\
    you or someone else entered this email address when trying to change the password of a app.domain.com portal user.\n\n\
    However, we could not find the email address in your account. Please contact the administrator of your \
    account to set your email address and password. If you are the administrator of the account,\
    please use the email address that you registered with.\n\n\
    If you were not expecting this email, please ignore it. In case of questions, please get in contact with the administrator of app.domain.com portal. \n\n\
    Kind regards,\n\
    app.domain.com support team\n',
    'passwordReset.success.email.template' => 'Dear app.domain.com user,\n\n\
    Your password on {host} has been recently changed. \n\
    If you or your administrator made this change, you do not need to do anything more. \n\
    If you did not make this change, please contact your administrator.\n\n\
    Kind regards,\n\
    app.domain.com support team\n',
    'passwordReset.invite.template' => 'Hi there,\n\n\
    Please use the following link to reset your password: \n\
    {host}/apps/devicemanagement/index.html?token={token}\n\n\
    If you were not expecting this email, please ignore it. \n\n\
    Kind regards,\n\n\
    app.domain.com support team\n"
    }
  },

  'cumulocity-external-lb' => {
    'landing_page' => 'https://4pawel.c8y.io/apps/devicemanagement',
    'paas_default_page' => 'https://$http_host/apps/$defapp',
    'paas_public_default_page' => 'https://4pawel.c8y.io/apps/dmpublic',
    'usePostgresForPaaS' => false,
    'paas_redirection' => true,
    'temp_chunkin' => false,
    'useIPAddress' => true,
    'useSSL' => true,
    'useHSTS' => false,
    'useMQTTsupport' => true,
    'useMQTTlogs' => false,
    'useMasterForPushOperations' => false,
    'useKarafWebsocket' => true,
    'proxy_cache' => true,
    'certificate_domain' => 'staging.c8y.io',
    'useLUAforLimits' => true,
    'useLUAforSSLcerts' => true,
    'useLUAforHealthCheck' => true,
    'nginx' => {
      'NGinxPort' => 'openresty',
      'version' => '1.11.2.4-20.el7.centos.c8y.8.11.1'
    }
  },

  'vendme-platform-agent' => {
    'use-internal-proxy' => nil,
    'install-agent' => nil,
    'install-platform' => nil,
    'install-tracker' => nil
  },

  'cumulocity-rsyslog' => {
    'cross-env-log-server' => 'cumulocity-multinode-prod',
    'log-server-ext-address' => 'monitoring.cumulocity.com'
  },

  'cumulocity-opsmanager' => {
    'mmsGroupId' => '5c471c8c98ff42295849628d',
    'mmsApiKey' => '5c471c9398ff4229584962afebf6b2b1df5fd3f52e8610d9da0741a3',
    'mmsBaseUrl' => 'http://ip-172-31-28-30.eu-central-1.compute.internal:8080',
    'serverPackageUrl' => 'https://downloads.mongodb.com/on-prem-mms/rpm/mongodb-mms-4.0.7.50349.20190109T1059Z-1.x86_64.rpm'
  }
)
