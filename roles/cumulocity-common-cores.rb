name "cumulocity-common-cores"
description "Cumulocity Multinode Core Karaf"

override_attributes(
  "ulimit": {
    "users": {
      "root": {
        "filehandle_soft_limit": 10240,
        "filehandle_hard_limit": 20480,
        "process_soft_limit": 1024,
        "process_hard_limit": 2048
      },
      "karaf": {
        "filehandle_soft_limit": 20240,
        "filehandle_hard_limit": 30480,
        "process_soft_limit": 3072,
        "process_hard_limit": 8000
      },
      "nginx": {
        "filehandle_soft_limit": 1024,
        "filehandle_hard_limit": 8192,
        "process_soft_limit": 1024,
        "process_hard_limit": 2048
      }
    }
  },
      "systemd": {
        "ulimits": {
            "DefaultLimitNOFILE": 30480,
            "DefaultLimitNPROC": 8000,
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
      "userCache.timeToLiveSeconds" => "1"
    }
  }
)

run_list(
 "role[cumulocity-base]",
 "role[cumulocity-internal-lb]",
 "recipe[cumulocity::core]",
 "role[cumulocity-external-lb]"
)
