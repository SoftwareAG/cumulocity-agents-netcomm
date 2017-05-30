name "cumulocity-external-lb"
description "Cumulocity External LB"

override_attributes(
  "ulimit" => {
    "root" => {
      "nofile" => {
        "soft" => "10240",
        "hard" => "20480"
      },
      "nproc" => {
        "soft" => "1024",
        "hard" => "2048"
      }
    },
    "nginx" => {
      "nofile" => {
        "soft" => "10240",
        "hard" => "20480"
      },
      "nproc" => {
        "soft" => "1024",
        "hard" => "2048"
      }
    }
  }
)

run_list(
 "role[cumulocity-base]",
 "recipe[cumulocity::external-lb]"
)
