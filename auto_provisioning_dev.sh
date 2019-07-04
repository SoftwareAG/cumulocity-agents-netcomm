#!/bin/bash

export CUMULOCITY_KUBERNETES_IMAGE="9.16.2"
export CUMULOCITY_KARAF_IMAGE="9.16.2-1"
export CUMULOCITY_KARAF_SSA="9.16.2-1"
export CUMULOCITY_GUI="9.16.2"
export MODULES_LIST=cep,cep-small,device-simulator,smartrule,jwireless,apama-small,billwerk-agent-server,connectivity-agent-server,branding,cellid-agent-server,remote-access,speech-agent-server

cd ./environments/ && ./set_versions.sh jenkins.json

knife environment from file auto_provisioning_env.json

cd ..
echo "Remove old vault"
bundle exec knife vault delete secrets cumulocity-staging-jenkins-nonprod.core -M client -y
bundle exec knife vault delete secrets cumulocity-staging-jenkins-nonprod.docker -M client -y

echo "First run"
bundle exec chef-client -l info -z provisioning/cumulocity-staging-jenkins-frankfurt-nonprod_2.rb

echo "Add new vaults"
bundle exec knife vault create secrets cumulocity-staging-jenkins-nonprod.docker -A 'admin12' -M client -S 'name:*' -J .chef/secrets/cumulocity-staging-jenkins-frankfurt-nonprod.docker.json
bundle exec knife vault create secrets cumulocity-staging-jenkins-nonprod.core -A 'admin12' -M client -S 'name:*' -J .chef/secrets/cumulocity-staging-jenkins-frankfurt-nonprod.core.json

echo "Second run"
bundle exec chef-client -l info -z provisioning/cumulocity-staging-jenkins-frankfurt-nonprod_2.rb
