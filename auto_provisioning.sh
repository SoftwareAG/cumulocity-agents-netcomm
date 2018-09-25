#!/bin/bash

export CUMULOCITY_KUBERNETES_IMAGE="9.8.9"
export CUMULOCITY_KARAF_IMAGE="9.8.9-1"
export CUMULOCITY_KARAF_SSA="9.8.9-1"
export CUMULOCITY_GUI="9.8.9"

cd ./environments/ && ./set_versions.sh jenkins.json

knife environment from file auto_provisioning_env.json

cd ..
bundle exec knife vault delete secrets cumulocity-staging-jenkins-nonprod.core -M client -y
bundle exec knife vault delete secrets cumulocity-staging-jenkins-nonprod.docker -M client -y

bundle exec chef-client -l info -z provisioning/cumulocity-staging-jenkins-frankfurt-nonprod.rb
bundle exec knife vault create secrets cumulocity-staging-jenkins-nonprod.docker -A 'admin12' -M client -S 'name:*' -J .chef/secrets/cumulocity-staging-jenkins-frankfurt-nonprod.docker.json
bundle exec knife vault create secrets cumulocity-staging-jenkins-nonprod.core -A 'admin12' -M client -S 'name:*' -J .chef/secrets/cumulocity-staging-jenkins-frankfurt-nonprod.core.json

bundle exec chef-client -l info -z provisioning/cumulocity-staging-jenkins-frankfurt-nonprod.rb