#!/bin/bash

export CUMULOCITY_KUBERNETES_IMAGE="9.8.9"
export CUMULOCITY_KARAF_IMAGE="9.8.9-1"
export CUMULOCITY_KARAF_SSA="9.8.9-1"
export CUMULOCITY_GUI="9.8.9"

cd ./environments/ && ./set_versions.sh jenkins.json

knife environment from file auto_provisioning_env.json

cd ..

bundle exec chef-client -z provisioning/cumulocity-staging-jenkins-frankfurt-nonprod.rb
