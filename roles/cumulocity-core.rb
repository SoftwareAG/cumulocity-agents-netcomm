name "cumulocity-core"
description "Cumulocity Core Karaf"

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
    "karaf" => {
      "nofile" => {
        "soft" => "10240",
        "hard" => "20480"
      },
      "nproc" => {
        "soft" => "2048",
        "hard" => "4096"
      }
    },
    "nginx" => {
      "nofile" => {
        "soft" => "1024",
        "hard" => "8192"
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
 "recipe[cumulocity::core_haproxy]",
 "recipe[cumulocity::core]"
)
