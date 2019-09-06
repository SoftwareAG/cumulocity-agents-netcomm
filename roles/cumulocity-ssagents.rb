name "cumulocity-ssagents"
description "This is a role to indicate the place where SSAgents should be deployed"

override_attributes(
  "ulimit": {
    "users": {
      "root": {
        "filehandle_soft_limit": 10240,
        "filehandle_hard_limit": 20480,
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
      }
)

run_list(
    "role[cumulocity-base]",
    "recipe[cumulocity::internal-lb]",
    "recipe[cumulocity-ssagents]"
)

