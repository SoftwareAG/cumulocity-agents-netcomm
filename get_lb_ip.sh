#!/bin/bash
knife search "node_name:cumulocity-staging-jenkins-nonprod_lb1" -F json | jq '.rows |= sort_by(.name) | .rows[] | .automatic.cloud_v2.public_ipv4'