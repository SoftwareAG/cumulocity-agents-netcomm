name "cumulocity-opsmanager-backing"
description "Ops Manager backing storage setup"

run_list(
  "recipe[cumulocity::mongo]",
  "recipe[cumulocity-opsmanager::backing]",
)

override_attributes(
  "useVaults" => false,
  "systemd": {
    "ulimits": {
      "DefaultLimitNOFILE": 128000,
      "DefaultLimitNPROC": 128000,
    }
  },
  "cumulocity-mongo" => {
    "sharedkey-content" => "", # don't enable authorization
    "mongodb.initUser" => "init-root",
    "mongodb.initPassword" => "ohH4Eele",
    "initRunUser" => "mongod",
    "initRunGroup" => "mongod"
  }
)
