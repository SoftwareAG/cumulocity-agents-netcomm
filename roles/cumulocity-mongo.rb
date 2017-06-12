name "cumulocity-mongo"
description "Mongo setup for replica sets"

override_attributes(

  "ulimit": {
    "users": {
      "root": {
        "filehandle_soft_limit": 60000,
        "filehandle_hard_limit": 64000,
        "process_soft_limit": 60000,
        "process_hard_limit": 64000
      },
      "mongod": {
        "filehandle_soft_limit": 60000,
        "filehandle_hard_limit": 64000,
        "process_soft_limit": 60000,
        "process_hard_limit": 64000
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
