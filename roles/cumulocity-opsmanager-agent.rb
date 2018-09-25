name "cumulocity-opsmanager-agent"
description "Ops Manager agent setup"

run_list(
  "recipe[cumulocity-opsmanager::agent]",
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
