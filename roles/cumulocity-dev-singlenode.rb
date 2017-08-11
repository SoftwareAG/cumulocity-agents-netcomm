
name "cumulocity-dev-singlenode"
description "Cumulocity Singlenode (Sandbox)"

default_attributes(
  "bigcouch" => {
    "admin"=>{
      "username"=> "couch-root",
      "password"=> "Moabit-123#",
      "hashed_password"=> "-hashed-5df2e2616985179b0f0a6e1164b50169e6dfcdaf,17e7743a3c8fd2aa2c5e73c7bf9d8efd"
    }
  }
)

override_attributes(
  "domainname" => "cumulocity.com",
  "ddclient" => {
    "login" => "13107q-m2mdyndns",
    "password" => "p2AN8xG9)e.K",
    "use" => "web, web=checkip.dyndns.com/, web-skip='IP Address'",
    "server" => "members.dyndns.org"
  },
  "java" => {
     "jdk_version" => "8"
  },
   "databags" => {
     "users" => :users_cumulocity_dev
  },
  "ulimit" => {
    "postgres" => {
      "nofile" => {
        "soft" => "1024",
        "hard" => "8192"
      },
      "nproc" => {
        "soft" => "1024",
        "hard" => "2048"
      }
    },
    "karaf" => {
      "nofile" => {
        "soft" => "10240",
        "hard" => "20480"
      },
      "nproc" => {
        "soft" => "2048",
        "hard" => "4096"
      }
    },
    "nginx" => {
      "nofile" => {
        "soft" => "1024",
        "hard" => "8192"
      },
      "nproc" => {
        "soft" => "1024",
        "hard" => "2048"
      }
    },
    "bigcouch" => {
      "nofile" => {
        "soft" => "256000",
        "hard" => "384000"
      },
      "nproc" => {
        "soft" => "unlimited",
        "hard" => "unlimited"
      }
    }
  }, 
  "tool_list" => ["htop", "mc", "screen"],
  "agent_server_list" => ["jwireless-agent-server","smartrule-agent-server-esper","device-simulator-agent-server"],
  "bigcouch" => {
    "cluster" => {
      "number-of-shard-copies" => "1",
      "number-of-shards" => "3"
    }
  },
  "cumulocity-mongo" => {
    "mongodb.initUser" => "init-root",
    "mongodb.initPassword" => "edf933ds^5fff"
  },
  "cumulocity-core" => {
    "properties" => {
      "dbinit.enabled" => "true",
      "contextService.rdbmsUser" => "postgres",
      "mongodb.host" => "localhost",
      "mongodb.admindb" => "admin",
      "mongodb.user" => "c8y-root",
      "couchClient.host" => "localhost",
      "couchClient.port" => "5984",
      "couchClient.user" => "couch-root",
      "couchClient.password" => "Moabit-123#",
      "management.admin.password" => "d59651ad01af3df933cd9c1167fc25c91d6133949efaf517632ee921c59c6aa4",
      "admin.password" => "4a893cafa79e1dd5a028a062d021994201c06eeaa463cc598a75fa88a95623af",
      "sysadmin.password" => "d8c38236ed79bbcfb580698e6d2f3dfba8af37209e45f1a58484e150aa6fceb9"
    }
  },
  "cumulocity-karaf" => {
    "notification" => nil,
    "oort-enabled" => nil,
    "cep-server-enabled" => true,
    "CUMULOCITY_LICENCE_DIR" => "/tmp"
  },
  "cumulocity-external-lb" => {
    "paas_redirection" => true,
    "useIPAddress" => true,
    "vendon_simulator" => true,
    "temp_chunkin" => false,
    "useHSTS" => true,
    "useMQTTsupport" => true,
    "usePostgresForPaaS" => false,
    "useKarafWebsocket" => true
  },
  "swap" => {
    "swapfile_block_size" => 768
  }
)

run_list(
 "role[cumulocity-base]",
 "recipe[cumulocity::postgres]",
 "recipe[cumulocity::mongo]",
 "recipe[cumulocity::core]",
 "recipe[cumulocity::core_cep]",
 "recipe[cumulocity::karaf_cep]",
 "recipe[cumulocity::karaf_dev-x-agents]",
 "recipe[cumulocity::external-lb]"
)
