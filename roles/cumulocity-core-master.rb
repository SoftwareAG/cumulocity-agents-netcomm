name "cumulocity-core-master"
description "Cumulocity Core Karaf Master"

override_attributes(
  "cumulocity-core" => {
    "properties" => {
      "dbinit.enabled" => "true"
    }
  }
)

run_list(
 "role[cumulocity-core]"
)
