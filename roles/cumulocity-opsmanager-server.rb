name "cumulocity-opsmanager-server"
description "Ops Manager server setup"

run_list(
  "recipe[cumulocity-opsmanager::server]",
)

override_attributes(
  "useVaults" => false,
  "systemd": {
    "ulimits": {
      "DefaultLimitNOFILE": 128000,
      "DefaultLimitNPROC": 128000,
    }
  },
)
