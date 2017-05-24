name "cumulocity-mongo"
description "Mongo setup for replica sets"

override_attributes(
  "ulimit" => {
    "root" => {
      "nofile" => {
        "soft" => "60000",
        "hard" => "64000"
      },
      "nproc" => {
        "soft" => "60000",
        "hard" => "64000"
      }
    },
    "mongod" => {
      "nofile" => {
        "soft" => "60000",
        "hard" => "64000"
      },
      "nproc" => {
        "soft" => "60000",
        "hard" => "64000"
      }
    }
  },
  "nagios" => {
    "checks" => {
      "memory" => {
        "warning" => 4,
        "critical" => 1
      }
    }
  }
)


run_list(
  "role[cumulocity-base]",
  "recipe[cumulocity::mongo]"
)
