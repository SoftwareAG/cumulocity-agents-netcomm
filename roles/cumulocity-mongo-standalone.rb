name "cumulocity-mongo-standalone"
description "This is a dummy role just to indicate that the specific node is ACTIVE mongo standalone node to redirect the traffic to it without mongoS"

run_list(
  "role[cumulocity-mongo-standalone]"
)
