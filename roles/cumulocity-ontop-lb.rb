name "cumulocity-ontop-lb"
description "Cumulocity External LB"

override_attributes(
  "cumulocity-external-lb" => {
    "apps_redirection" => true
  }
)

run_list(
 "role[cumulocity-base]",
 "recipe[cumulocity::external-lb]"
)
