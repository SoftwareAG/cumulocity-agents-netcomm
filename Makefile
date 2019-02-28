build:
	docker build -t chef_workstation .

run_myorg:
	docker run -it --rm \
	  --name myorg_chef_workstation \
		-v $(PWD):/usr/src/app \
		-v ~/.aws:/root/.aws \
		-v $(PWD)/../cumulocity-cookbooks:/usr/src/cumulocity-cookbooks \
		-e ORGNAME=myorg \
		chef_workstation bash

run_cumulocity-devel:
	docker run -it \
		-v $(PWD):/usr/src/app \
		-v ~/.aws:/root/.aws \
		-v $(PWD)/../cumulocity-cookbooks:/usr/src/cumulocity-cookbooks \
		-e ORGNAME=cumulocity-devel chef_workstation bash

run_cumulocity-stagings:
	docker run -it \
		-v $(PWD):/usr/src/app \
		-v ~/.aws:/root/.aws \
		-v $(PWD)/../cumulocity-cookbooks:/usr/src/cumulocity-cookbooks \
		-e ORGNAME=cumulocity-stagings chef_workstation bash


upload_cumulocity_cookbooks:
	bundle exec berks upload cumulocity --force
	bundle exec berks upload cumulocity-backup-script --force
	bundle exec berks upload cumulocity-kubernetes --force
	bundle exec berks upload cumulocity-monit --force
	bundle exec berks upload cumulocity-ssagents --force

deploy_myorg_small:
	bundle exec berks upload cumulocity --force
	bundle exec berks upload cumulocity-kubernetes --force
	bundle exec chef-client -z provisioning/cumulocity-4felix-allinone-nonprod-c8y-small.rb