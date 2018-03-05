name "cumulocity-ontop-lb"
description "Cumulocity External LB"

override_attributes(
  "cumulocity-external-lb" => {
    "apps_redirection" => true
  },
  "ulimit": {
    "users": {
      "root": {
        "filehandle_soft_limit": 10240,
        "filehandle_hard_limit": 20480,
        "process_soft_limit": 1024,
        "process_hard_limit": 2048
      },
      "nginx": {
        "filehandle_soft_limit": 10240,
        "filehandle_hard_limit": 20480,
        "process_soft_limit": 1024,
        "process_hard_limit": 2048
      }
    }
  },
    "systemd": {
        "ulimits": {
            "DefaultLimitNOFILE": 20480,
            "DefaultLimitNPROC": 3072,
        }
    }
)

run_list(
 "role[cumulocity-base]",
 "recipe[cumulocity::external-lb]"
)
