name "kpn-prod"

description "The KPN production environment"

default_attributes(
 'fixhostname' => false,
 'fixhostsfile' => false,
 "elb" => {
      "name" => "production"
    }
)
override_attributes(
  "chef_client" => {
        "server_url" => "https://g6vp-a-chef"
  },
  "ntp" => {
    "servers" => [ '192.168.2.56', '80.79.97.161','80.79.97.160','0.pool.ntp.org','1.pool.ntp.org','2.pool.ntp.org','3.pool.ntp.org' ]
  },
  "domainname" => "kpnthings.com",
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
    "address" => "manage.kpnthings.com"
  },
  "java" => {
     "jdk_version" => "8"
  },
#  "nagios" => {
#    "server" => {
#        "version" => "3.4.3",
#        "checksum" => "adb04a255a3bb1574840ebd4a0f2eb76"
#        }
#    },
  "cumulocity-kubernetes" => {
     "deployK8S4env" => "kpn-prod",
     "attachedEnvs" => ["kpn-prod"],
     "token" => "fb6k6j.hmh8vlcggyipqelf",
     "images-connString" => "https://K8Simages:K8S^imAgEs5000%@resources.cumulocity.com/kubernetes-images",
     "images-version" => "8.19.33",
#     "images2install" => [ "cep" ],
     "images2install" => [  ],
     "heapster" => {
       "enabled" => true
     }
  },
  "cumulocity-karaf" => {
    #"version" => "8.19.33-1",
    "version" => "9.12.9-1",
    #"ssa-version" => "8.19.33-1",
    "ssa-version" => "9.12.9-1",
    "memory_left_for_system" => "6144",
    "notification" => true,
    "oort-enabled" => true,
    "cep-server-enabled" => true,
#    "cep-server-enabled" => false,
    "CUMULOCITY_LICENCE_KEY" => "91c52fa50d38fc95caf6018735d4ef42980466c23d967283a7f04bbb22d76198864d2b61ab207c78323003e679c54934bc63d48c0f957b7a5c87cf2f05200ddf",
    "openrelayIP" => "145.222.27.185"
  },
#  "cumulocity-GUI" => {
#      "version" => "8.19.33",
#      "connString" => "http://resources.cumulocity.com/webapps/ui-releases/"
#  },
#  "cumulocity-postgres" => {
#        "isMasterHotStandby" => true,
#        "replicator.password" => "repL1cat0r"
#  },
  "cumulocity-core" => {
    "properties" => {
      #"contextService.rdbmsURL" => "jdbc:postgresql://192.168.2.62",
      "contextService.rdbmsURL" => "jdbc:postgresql://localhost",
      "contextService.rdbmsDriver" => "org.postgresql.Driver",
      "contextService.rdbmsUser" => "postgres",
      "mongodb.user" => "c8y-root",
      "mongodb.admindb" => "admin",
      "contextService.tenantManagementDB" => "management",
      "cumulocity.environment" => "PRODUCTION",
      "auth.checkBlockingFromOutside" => false,
      "default.tenant.applications" => "administration,devicemanagement,cockpit,feature-microservice-hosting,feature-cep-custom-rules",

      # 8.15 credentials
      "management.admin.password" => "d5ae97561d85a56975aa4a5175f6bda72ab92bf42e0b89196bc962a2d85af0b4",
      "tenant.admin.password" => "d5ae97561d85a56975aa4a5175f6bda72ab92bf42e0b89196bc962a2d85af0b4",
      "admin.password" => "d5ae97561d85a56975aa4a5175f6bda72ab92bf42e0b89196bc962a2d85af0b4",
      # 8.19 credentials
      #"management.admin.password" => "96432d2970d8c60c75a8f15fd16c52b2963e32f8eca1a16af18f803692370465",
      #"tenant.admin.password" => "ba173e85260f8cee1b1bad8208e04f1257e9e5c11c7beb0746b4195d2267a077",
      #"admin.password" => "d0f7ef2ad118981de5065a91b5656c27cb7ccb9daf6235d2afea80e246649508",

      #"system.two-factor-authentication.enabled" => false,
      #"system.two-factor-authentication.enforced.group" => "admins",
      #"system.two-factor-authentication.host" => "http://${SMS-GATEWAY-SERVER}:8688/sms-gateway",
      #"system.two-factor-authentication.senderAddress" => "",
      #"system.two-factor-authentication.senderName" => "KPN",
      #"system.two-factor-authentication.logout-on-browser-termination" => true,
      #"system.two-factor-authentication.max.inactive" => "14",
      #"system.two-factor-authentication.provider" => "ntt",
      #"system.two-factor-authentication.ntt.baseUrl" => "https://m1free.rcs.msg.ntt.com/messaging/v1/sms/outbound/acr%3Acumulocity/requests",
      #"system.two-factor-authentication.ntt.baseUrl" => "https://free.rcs.ntt.com/messaging/v1/sms/outbound/acr%3Acumulocity/requests",
      #"system.two-factor-authentication.ntt.username" => "cumulocity",
      #"system.two-factor-authentication.ntt.password" => "",
      ## Added 01.05.2018 by KPN PEN request, default value is 100
      "system.authentication.badRequestCounter" => "5",

      "default.tenant.microservices" => "device-simulator, smartrule, cep",
#      "migration.tomongo.default" => "POSTGRES_READ_WRITE",
      "migration.tomongo.default" => "MONGO_READ_WRITE",
      #"tenant.admin.grants.disabled" => true,
      "system.support-user.enabled" => true,
      "tenantSuspend.mail.sendtosuspended" => false,
      #"tenantSuspend.mail.additional.address" => "operations@cumulocity.com",
#      "device-simulator.microservice.url" => "http://${DEVICE-SIMULATOR-AGENT-SERVER}:6666",
#      "smartrule.microservice.url" => "http://${SMARTRULE-AGENT-SERVER-ESPER}:8334",
      "email.from" => "no-reply@kpnthings.com",
      "errorMessageRepresentationBuilder.includeDebug" => "false",
      "passwordReset.email.subject" => "Password reset",
      "passwordReset.token.email.template" => 'Dear KPN user,\n\n\
            You or someone else entered this email address when trying to change the password of a KPN portal user.\n\n\
            Please use the following link to reset your password: \n\
            {host}?token={token}&showTenant\n\n\
            If you were not expecting this email, please ignore it. \n\n\
            Kind regards,\n\
            KPN support team\n',
      "passwordReset.user.not.found.email.template" => 'Hi there,\n\n\
            you or someone else entered this email address when trying to change the password of Za KPNportal user.\n\n\
            However, we could not find the email address in your account. Please contact the administrator of your \
            account to set your email address and password. If you are the administrator of the account,\
            please use the email address that you registered with.\n\n\
            If you were not expecting this email, please ignore it. In case of questions, please get in contact with the administrator of the KPN Tesbed portal. \n\n\
            Kind regards,\n\
            The KPN support team\n',
      "passwordReset.success.email.template" => 'Dear KPN user,\n\n\
            Your password on {host} has been recently changed. \n\
            If you or your administrator made this change, you do not need to do anything more. \n\
            If you did not make this change, please contact your administrator.\n\n\
            Kind regards,\n\
            Your KPN support team\n',
      "passwordReset.invite.template" => 'Hi there,\n\n\
            Please use the following link to reset your password: \n\
            {host}/apps/devicemanagement/index.html?token={token}\n\n\
            If you were not expecting this email, please ignore it. \n\n\
            Kind regards,\n\n\
            Your KPN support team\n'
    }
  },
    "cumulocity-mongo" => {
        'initRunUser' => 'mongod',
        'initRunGroup' => 'mongod',
        'members-check' => true,
        #"installEnterprise" => true, # migration change
        "wiredtiger-cache" => 8,
        "sharedkey-content" => "sfa8RqCHtfciBGmUJD78wSbrwkacWEwWYnkI4x3TXdUDEqCgOgVqABzggl8WT8xg\nxcqeosnEopvdJrhdKgoIABdbcvvYrluL0Ks4Rng6ew3uBMbFoQ5uveIDes/9y1Oz\n6PBWbFCS84sBKXv2oDM+WPTkZpKUW6MVznjWFVCL55Yf/auO1hPPkKDctraEOM3D\nJFwMXo5yW39n/Nh2Fl6zk9lIUNpFFTJJ2v1C4O6x7AJJAQPczGB3Ih9VoE4GizC4\nDkAUeMMvVWdZ19WpqT/ymmo+kXX75WTh0m0afTI06PdSEYOkHgC4WGVGjMny4//3\nZy8AzbiUSsN0oVXz2YkbPhlHAtUqxVtPQdxHhfcsWLiFZuRwZBtwCdwEncC3zelX\nQrTOJWCMBULGh8LzAPMFh8qw3YYidxK46yLY0G3J1heqD8G/hyuBs7HCLVBtHm5H\nD1ikq+2t2XJUUlrUinvuzjn1nWMyg+4GgwA7eEUujOPWQchvtLS06Di8CzU+PNpS\n1SI2/VLdD7BQ/cpmbm6OTdwfPpFq/zoUzMnmAxyM8Ckc9NiHmqJbfLu7BPt2i4v5\nd8E3YUJ4D6oe5CAEG4oWWH5qcmjdWgC1NQjd8fBMPS5BeQng4Muq3QqGv0rIrfDz\nlR0VDywTnPJ/JZCqT43o6O/AQKL8sjA5vydL7ZRTZzjEkBbQKYiXGtKMOnk0ow5a\nh37BrENgCb/aMFn7u7F5F3ufNt1pbz839zuKEwgLDFze1s0ChJkGelRQosaBijze\nVkJTG2Ln6c6Wf+7emQhdn6K86V6RTvHXprFXvgvcw9YispfcFP8Giq4SbsyHwjk6\nzw2dLpPXy3vYF/G9kLqML5CNS0uT+wdRjFZ0lKPHyUkGzt1ZCuGEIYrI26PqrTdk\n+YU18DQh2VMmuRgxZUWVuWyjSPXP3cdIth/50py8JV8B96pbnXnqtag+NrFLwc/3\nT4nTBvEPTLrK3Kmeo/B6E1XXkiMU",
        "mongodb.initUser" => "init-root",
#        "mongodb.initPassword" => "<mongoinitroot_password>"
  },
    "cumulocity-external-lb" => {
        "landing_page" => "https://kpnthings.com/apps/devicemanagement",
        "paas_default_page" => "https://$http_host/apps/$defapp/",
        "paas_public_default_page" => "https://kpnthings.com/apps/dmpublic",
        "usePostgresForPaaS" => false,
        "paas_redirection" => true,
        "proxy_cache" => true,
        "useIPAddress" => true,
        "useMQTTsupport" => true,
        "useSSL" => true,
        "force_proto_for_link_processor" => "https",
	"certificate_domain" => "kpnthings.com",
#       "certificate_domain" => "cumulocity.com",
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
    "cumulocity-ssagents" => {
	"useTags" => true,
	"ssAgentsIP" => "192.168.4.11",
  },

    'cumulocity-rsyslog' => {
#      'cross-env-log-server' => "cumulocity-multinode-dr",
#      'log-server-ext-address' => "monitoring.cumulocity.com"
  },
   "cumulocity-cep" => {
       "properties" => {
         " esperha.storage" => "/mnt/esperha-storage/"
     },
  },

"openssh" => {
  "server" => {
    "accept_env" => "LANG LC_CTYPE LC_NUMERIC LC_TIME LC_COLLATE LC_MONETARY LC_MESSAGES LC_PAPER LC_NAME LC_ADDRESS LC_TELEPHONE LC_MEASUREMENT LC_IDENTIFICATION LC_ALL LANGUAGE XMODIFIERS",
    "banner" => "/etc/ssh/banner",
#    "challenge_response_authentication" => "no",
    "client_alive_count_max" => "3",
    "client_alive_interval" => "360",
#    "host_key" => "/etc/ssh/ssh_host_rsa_key",
#    "host_key" => "/etc/ssh/ssh_host_dsa_key",
    "hostbased_authentication" => "no",
    "ignore_rhosts" => "yes",
    "log_level" => "INFO",
    "login_grace_time" => "60",
    "password_authentication" => "no",
    "permit_empty_passwords" => "no",
    "permit_root_login" => "no",
    "port" => "22",
    "print_last_log" => "yes",
    "print_motd" => "yes",
    "protocol" => "2",
    "pubkey_authentication" => "yes",
    "r_s_a_authentication" => "yes",
    "rhosts_r_s_a_authentication" => "no",
    "strict_modes" => "yes",
#    "subsystem" => "sftp /usr/libexec/openssh/sftp-server",
    "syslog_facility" => "AUTHPRIV",
    "t_c_p_keep_alive" => "yes",
    "use_login" => "no",
#    "use_p_a_m" => "yes",
    "use_privilege_separation" => "yes",
    "x11_display_offset" => "10",
    "x11_forwarding" => "yes",
    "allow_groups" => "ssh-users"
  }
}

)

#cookbook_versions(ChefConfig.cookbook_versions_for_env)
