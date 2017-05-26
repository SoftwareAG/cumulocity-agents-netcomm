name "cumulocity-common-dbs-standalone-mongo"
description "Cumulocity Common DBs Node"

run_list(
 "role[cumulocity-base]",
 "role[cumulocity-sql-db]",
 "role[cumulocity-mongo]"
)
