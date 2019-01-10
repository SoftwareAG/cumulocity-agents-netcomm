name "<customer>-graylog"

description "The <Customer> graylog environment"

default_attributes(
 "elb" => {
      "name" => "production"
    }
)
override_attributes(
  "java" => {
     "jdk_version" => "8"
  },
  "elasticsearch" => {
	"version" => "5.1.1",
	"user" => "elasticsearch",
	"data_dir" => "/opt/elasticsearch",
	"install_method" => "package",
	"config_v5" => {
		"cluster.name" => "graylog",
		"bootstrap.memory_lock" => false,
		"path.data" => "/opt/elasticsearch",
		"discovery.zen.ping.unicast.hosts" => [ <list of elasticsearch internal ip addresses>  ]
	},
	"cluster" => {
      		"name" => "graylog"
    	}
  },
  "mongodb" => {
	"install_method" => "mongodb-org",
	"config" => {
		"mongod" => {
			"storage" => {
				"dbPath" => "/opt/mongodb"
			}
		}
	}
  },
  "graylog2" => {
	"ip_of_master" => "<ip of first graylog server>",
	"elasticsearch" => {
		"node_search_query" => "role:elasticsearch",
		"node_search_attribute" => "ipaddress"
	},
	"server" => {
		"java_opts" => "-Djava.net.preferIPv4Stack=true"
	},
	"password_secret" => "4uiGLlNyU2u9RdtUTs5dYFSWM1KMdHKLwLkM0I8sR1b66R81LSOplqEfyNm2mqpCkBotoq2kdVAQybCmstEgXacpG3xhZT4x",

	# !!47Neun271
	"root_password_sha2" => "a5fc7c03f782372da444bf389b754ca3fcfa312cdc121fc8cd7107216419cd3d",

	"mongodb" => {
		"uri" => "mongodb://<ip_of_mongodb_server>:27017/graylog"
	},
	"rest" => {
		"listen_uri" => "http://0.0.0.0:9000/api/"
	},
	"web" => {
                "listen_uri" => "http://0.0.0.0:9000/",
		"endpoint_uri" => "http://<external_ip_or_url>:9000/api"
        }
  }
  

)

#cookbook_versions(ChefConfig.cookbook_versions_for_env)
