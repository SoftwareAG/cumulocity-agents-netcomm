# frozen_string_literal: true

name 'opsmanager-nonprod'
description 'Ops Manager nonprod environment'

cookbook_versions(
  'cumulocity' => '= 9.20.3',
  'cumulocity-opsmanager' => '= 9.20.3'
)

default_attributes(
  'fixhostname' => false,
  'fixhostsfile' => false,
  'useVaults' => false
)

override_attributes(
  'swapfilesize' => 0,
  'cumulocity-rsyslog' => {
    'cross-env-log-server' => 'cumulocity-multinode-prod',
    'log-server-ext-address' => 'monitoring.cumulocity.com'
  },
  'cumulocity-opsmanager' => {
    'mmsGroupId' => '5c4711a298ff422958492cc6',
    'mmsApiKey' => '5c47135e98ff4229584939f0f0587d9a1ae3f83728530888500b03d7',
    'mmsBaseUrl' => 'http://ip-172-31-28-30.eu-central-1.compute.internal:8080',
    'mongoUri' => 'mongodb://172.31.28.30:27019,172.31.28.31:27019,172.31.28.32:27019/?maxPoolSize=150&replicaSet=rs09'
  },
  'cumulocity-mongo' => {
    'initRunGroup' => 'mongod',
    'initRunUser' => 'mongod',
    'repo-version' => '4.0',
    'wiredtiger-cache' => 4
  },
  'cumulocity-karaf' => {
    'version' => '9.16.0-1'
  }
)
