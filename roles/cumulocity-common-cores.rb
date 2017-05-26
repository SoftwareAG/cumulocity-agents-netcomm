name "cumulocity-common-cores"
description "Cumulocity Multinode Core Karaf"

override_attributes(
  "ulimit" => {
    "root" => {
      "nofile" => {
        "soft" => "10240",
        "hard" => "20480"
      },
      "nproc" => {
        "soft" => "1024",
        "hard" => "2048"
      }
    },
    "karaf" => {
      "nofile" => {
        "soft" => "20240",
        "hard" => "30480"
      },
      "nproc" => {
        "soft" => "3072",
        "hard" => "8000"
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
    }
  },
  "cumulocity-karaf" => { # FIXME remove it once core is migrated to version > 0.19.0
    "properties-filenames" => []
  },
  "cumulocity-core" => {
    "properties" => {
      "dbinit.enabled" => "true", # FIXME remove all other properties once core is migrated to version > 0.19.0
      "http.server" => "",
      "linkTemplateProcessor.clientProtocolType" => "true",
      "errorMessageRepresentationBuilder.includeDebug" => "true",
      "errorMessageRepresentationBuilder.documentationBaseUrl" => "https://www.cumulocity.com/guides/reference-guide",
      "userCache.enabled" => "true",
      "tenantCache.timeToIdleSeconds" => "1",
      "tenantCache.timeToLiveSeconds" => "1",
      "userCache.timeToIdleSeconds" => "1",
      "userCache.timeToLiveSeconds" => "1",
      "dbinit.enabled" => "true"
    }
  }
)

run_list(
 "role[cumulocity-base]",
 "role[cumulocity-internal-lb]",
 "recipe[cumulocity-core]",
 "role[cumulocity-external-lb]"
)
