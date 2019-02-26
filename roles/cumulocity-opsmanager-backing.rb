name "cumulocity-opsmanager-backing"
description "Ops Manager backing storage setup"

run_list(
  "recipe[cumulocity::mongo]",
  "recipe[cumulocity-opsmanager::backing]",
)
