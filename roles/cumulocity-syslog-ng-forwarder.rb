name "cumulocity-syslog-ng-forwarder"
description "Cumulocity Developer Resources role for common YUM instance"

run_list(
  "role[cumulocity-base]",
  "recipe[cumulocity-syslog-ng-forwarder]"
)

