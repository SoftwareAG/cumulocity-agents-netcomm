name "cumulocity-kubernetes"
description "cumulocity-kubernetes"

run_list(
 "role[cumulocity-base]",
 "recipe[cumulocity-kubernetes]"
)