name "ooredoo-ha-dev-prod"

description "The Ooredoo development environment"

default_attributes(
 "elb" => {
      "name" => "production"
    }
)
override_attributes(
  "ntp" => {
    "servers" => [ '82.148.109.106,82.148.109.109' ]
  },
  "chef_client" => {
        "server_url" => "https://vuiotchef01.deviotsolutions.ooredoo.qa"
  },
  "domainname" => "deviotsolution.ooredoo.qa",
  'yum' => {
#    'proxy' => 'http://10.23.45.21:3128',
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
    "address" => "deviotsolution.ooredoo.qa"
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
     "deployK8S4env" => "ooredoo-ha-dev-prod",
     "attachedEnvs" => ["ooredoo-ha-dev-prod"],
     "token" => "1e3145.2ff901841c48af2e",
     "images-connString" => "https://K8Simages:K8S^imAgEs5000%@resources.cumulocity.com/kubernetes-images",
     "images-version" => "9.16.3",
     "images2install" => [ "" ],                                                                                                      
     "heapster" => {                                                                                                                                                
       "enabled" => true                                                                                                                                            
     }                                                                                                                                                              
  },                                                                                                                                                                
  "cumulocity-karaf" => {                                                                                                                                           
    "version" => "9.16.3-1",                                                                                                                                        
    "memory_left_for_system" => "4096",                                                                                                                             
    "notification" => true,                                                                                                                                         
    "oort-enabled" => true,                                                                                                                                         
    "cep-server-enabled" => true,                                                                                                                                   
    "ssa-version" => "9.16.3-1",                                                                                                                                    
    "openrelayIP" => "172.16.206.75",                                                                                                                               
    "CUMULOCITY_LICENCE_KEY" => "c6fd89fede7a55e9730231a49745c6291ed64169de10f8f425c53c0c416a0a1489c50cfdf88e31ae59c1fecab4a58c18442f1cd55c7fdda534f6b0374565dbe8"
  },                                                                                                                                                                
  "cumulocity-core" => {                                                                                                                                            
    "properties" => {                                                                                                                                               
      "contextService.rdbmsURL" => "jdbc:postgresql://localhost",                                                                                                   
      "contextService.rdbmsDriver" => "org.postgresql.Driver",                                                                                                      
      "contextService.rdbmsUser" => "postgres",                                                                                                                     
#      "system.connectivity.microservice.url" => "http://10.23.45.21:8092/jwireless",                                                                               
      "mongodb.user" => "c8y-root",                                                                                                                                 
      "mongodb.admindb" => "admin",                                                                                                                                 
      "contextService.tenantManagementDB" => "management",                                                                                                          
      "cumulocity.environment" => "PRODUCTION",                                                                                                                     
      "auth.checkBlockingFromOutside" => false,                                                                                                                     
      ## qtr:18:DOH                                                                                                                                                 
      "default.tenant.applications" => "administration,devicemanagement,cockpit,feature-cep-custom-rules",                                                          
      "management.admin.password" => "2347c297efe705f08a08b161ee70b7dc1d01768eece82d70fde2807d555772f5",                                                            
      "tenant.admin.password" => "2347c297efe705f08a08b161ee70b7dc1d01768eece82d70fde2807d555772f5",                                                                
      "admin.password" => "2347c297efe705f08a08b161ee70b7dc1d01768eece82d70fde2807d555772f5",                                                                       
      "cometd.heartbeat.minutes" => "4",                                                                                                                            
      "default.tenant.microservices" => "device-simulator, smartrule, cep, sms-gateway-server",                                                                     
      "system.support-user.enabled" => true,                                                                                                                        
      "smsGateway.host" => "http://10.23.45.21:8688",                                                                                                               
      "tenantSuspend.mail.sendtosuspended" => false,                                                                                                                
      "tenantSuspend.mail.additional.address" => "operations@ooredoo.qa",                                                                                       
      "device-simulator.microservice.url" => "http://${DEVICE-SIMULATOR-AGENT-SERVER}:6666",                                                                        
      "smartrule.microservice.url" => "http://127.0.0.1:8334",                                                                                                      
      "microservice.websocket.port" => 8303,           
      ## TFA                                                                                                                                                        
      #"system.two-factor-authentication.enabled" => true,                                                                                                           
      #"system.two-factor-authentication.enforced.group" => "admins",                                                                                                
      #"system.two-factor-authentication.enforced" => "soc,soc1",                                                                                                    
      #"system.two-factor-authentication.host" => "http://10.23.45.21:8688",                                                                                         
      #"system.two-factor-authentication.senderAddress" => "97466446784",                                                                                           
      #"system.two-factor-authentication.senderName" => "Ooredoo IoT",                                                                                               
      #"system.two-factor-authentication.max.inactive" => "43200",                                                                                                  
      # 30082018                                                                                                                                                    
      #"system.two-factor-authentication.max.inactive" => "1440",                                                                                                    
      #"system.two-factor-authentication.provider" => "gsm-one",                                                                                                     
      #"system.two-factor-authentication.token.sms.template" => "Ooredoo IoT - Verification Code: {token}",                                                          
      #"system.two-factor-authentication.pin.validity" => "29",                                                                                                     
      # 30082018                                                                                                                                                    
      #"system.two-factor-authentication.pin.validity" => "5",                                                                                                       
      # 12122018 (Zendesk 37627)                                                                                                                                    
      #"system.two-factor-authentication.senderAddress" => "Ooredoo IoT",                                                                                            
                                                                                                                                                                    
      "migration.tomongo.default" => "MONGO_READ_WRITE",                                                                                                            
      "email.from" => "no-reply@deviotsolution.ooredoo.qa",                                                                                                     
      "errorMessageRepresentationBuilder.includeDebug" => "false",                                                                                                  
      "passwordReset.email.subject" => "Password reset",                                                                                                            
      "passwordReset.token.email.template" => 'Dear Ooredoo IoT development environment user,\n\n\                                                                           
            You or someone else entered this email address when trying to change the password of a user.\n\n\                                   
            Please use the following link to reset your password: \n\                                                                                               
            {host}?token={token}&showTenant\n\n\                                                                                                                    
            If you were not expecting this email, please ignore it. \n\n\                                                                                           
            Kind regards,\n\                                                                                                                                        
            The Ooredoo Iot support team\n',                                                                                                         
      "passwordReset.user.not.found.email.template" => 'Hi there,\n\n\                                                                                              
            you or someone else entered this email address when trying to change the password of an Ooredoo IoT user.\n\n\                           
            However, we could not find the email address in your account. Please contact the administrator of your \                                                
            account to set your email address and password. If you are the administrator of the account,\                                                           
            please use the email address that you registered with.\n\n\                                                                                             
            If you were not expecting this email, please ignore it. In case of questions, please get in contact with the administrator of the IoT development portal. \n\n\                                                                                                                                                          
            Kind regards,\n\                                                                                                                                        
            The Ooredoo IoT support team\n',                                                                                                         
      "passwordReset.success.email.template" => 'Dear Ooredoo IoT development environment user,\n\n\                                                                         
            Your password on {host} has been recently changed. \n\                                                                                                  
            If you or your administrator made this change, you do not need to do anything more. \n\                                                                 
            If you did not make this change, please contact your administrator.\n\n\                                                                                
            Kind regards,\n\                                                                                                                                        
            Your Ooredoo IoT support team\n',                                                                                                        
      "passwordReset.invite.template" => 'Hi there,\n\n\                                                                                                            
            Please use the following link to reset your password: \n\                                                                                               
            {host}/apps/devicemanagement/index.html?token={token}\n\n\                                                                                              
            If you were not expecting this email, please ignore it. \n\n\                                                                                           
            Kind regards,\n\n\                                                                                                                                      
            Your Ooredoo IoT support team\n'                                                                                                         
    }                                                                                                                                                               
  },                               
    "cumulocity-mongo" => {                                                                                                                                         
       'initRunUser' => 'mongod',                                                                                                                                  
       'initRunGroup' => 'mongod',                                                                                                                                 
#       'members-check' => false, # default: true                                                                                                                   
#       "installEnterprise" => true, # migration change                                                                                                             
        "wiredtiger-cache" => 8,                                                                                                                                    
        "sharedkey-content" => "BNoGDBJwRE2jpD4BKbGxqfS5Lkx5jJs3PHR8LXy3VyaIP19S//ZuuQANTJoIaKzC\nERrE2K7yISMCaIVf8P6S7VUeY8u9CWLj0BwgA9KcmGGki7KrA0fnA2cF9WGLynoA\nkv2cQ5M0Itmi66UNoQAMnC7FnBqkq42JgcDkH0iNmsPz8Ul9b6RPXjrWDG55iS/D\nSJk/R6GApP3QgVgBym3xITi1Ui0Wzq8NO41wQM3N5V2HxoUr6VJISVf3ChRvZV84\nPoXI1BNc4UWYckvguva2jknObUGqE+Pzvx5pFSxQRcTWAzDOwKR+1otfle7wlSbg\ndx4vvHsmYUy7+z16Ip0/KA/tT6sCH0Z2jlOgQkgo9gzV4At635vEZIFNK3ZVoRV4\nrSmXF6uy2eA0XNuHBbCONk+7Juit35F+lYH/+3lHL5N6URthZnX02XgzKJbJkN/6\ndPpGz/+7KSM+biPcQwA8VfIzNoAjXAVN02zcbUEqYab/HTZwXIPasz+qAdibEW+5\nUomuOHeDDu7ut+sPp3Fo4fgqC7ufgBaTcmJrzBp33KS+QkIjwGGOpM8SkOeVWpX8\nSaYkUYByb6Wq5uNh/JSiQ+G81DzfVhuQDPQxv0g6kLAZvLaD2E2TDR3rCcCwy17Z\nlOzaq4fkCJcY4b2CKFg7veCfCCuUw8l6HCp3wDXCmpN2o2Z52BzYFhuVIvD//Jom\nIR/YDbIdibsvFcsEcDry1ynjWZTULk+X5+OEr+UWK3EvFzv2wh2olGTaaBRhm/VI\nA9SuQZqcPS6OHfPRcs1iFJhYmgvtpQZxZ3Thuh/cwN++UbUZusz4AOHUdgBokZ5y\nap2DJ6Mbghdi7nfkBIM+kaA16vrpQh2hocu+6N9wNCc4Em/QmkyF5zrFk5aOl/NU\n4rk8VZr5t8nU7Qt7p8fzkCvQ5Ge25vuBwlCsHKA/kuDYDImEFVJL8Fy8qJ3GsTzB\n8sk5BNIYCzx/ZuXgARhBAZ6oOBWW",                                                                                                
        "mongodb.initUser" => "init-root",                                                                                                                          
   "version" => "3.6"                                                                                                                                               
  },                                                                                                                                                                
    "cumulocity-external-lb" => {                                                                                                                                   
        "landing_page" => "https://deviotsolution.ooredoo.qa/apps/devicemanagement",                                                                            
        "paas_default_page" => "https://$http_host/apps/$defapp/",                                                                                                  
        "paas_public_default_page" => "https://deviotsolution.ooredoo.qa/apps/dmpublic",                                                                        
        "usePostgresForPaaS" => false,                                                                                                                              
        "paas_redirection" => true,                                                                                                                                 
        "proxy_cache" => true,                                                                                                                                      
        "useIPAddress" => true,                                                                                                                                     
        "useMQTTsupport" => true,                                                                                                                                   
        "useKarafWebsocket" => true,                                                                                                                                
        "useSSL" => true,                                                                                                                                           
        "certificate_domain" => "deviotsolution.ooredoo.qa",                                                                                                    
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
#  'cumulocity-rsyslog' => {                                                                                                                                         
#       'cross-env-log-server' => "10.23.42.52",                                                                                                                     
#       'log-server-ext-address' => "10.23.42.52",                                                                                                                   
#       'forward-to-graylog' => true,                                                                                                                                
#       'forward-on-port' => "5514"                                                                                                                                  
#    },                                                                                                                                                              
                                                                                                                                                                    
   "cumulocity-cep" => {                                                                                                                                            
       "properties" => {                                                                                                                                            
         " esperha.storage" => "/mnt/esperha-storage/"                                                                                                              
     },                                                                                                                                                             
  },                                      
                                                                                                                                                                    
   "cumulocity-ssagents" => {                                                                                                                                       
        "scriptDir" => "/root",                                                                                                                                     
        "useTags" => true,                                                                                                                                          
        "ssAgentsIP" => "10.16.106.164",                                                                                                                              
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
  }                                                                                                                                                                 
                                                                                                                                                                    
)                                                                                                                                                                   
                                                                                                                                                                    
#cookbook_versions(ChefConfig.cookbook_versions_for_env)     
