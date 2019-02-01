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
  'swapfilesize' => 0,
  'cumulocity-rsyslog' => {
    'cross-env-log-server' => 'cumulocity-multinode-prod',
    'log-server-ext-address' => 'monitoring.cumulocity.com'
  },
  'cumulocity-opsmanager' => {
    'mmsGroupId' => '5c4f17e68339d262a756075e',
    'mmsApiKey' => '5c4f188d8339d262a7560c2196cda0e40b414812c1be5fb8acffb828',
    'mmsBaseUrl' => 'http://ip-172-31-28-30.eu-central-1.compute.internal:8080',
    'mongoUri' => 'mongodb://172.31.28.30:27019,172.31.28.31:27019,172.31.28.32:27019/?maxPoolSize=150&replicaSet=rs09',
    'appBlock' => '/dev/nvme1n1',
    'dataBlock' => '/dev/mapper/data-vol0',
    'serverPackageUrl' => 'https://s3.amazonaws.com/mongodb-mms-build-onprem/8adb394e6f159f8768805b02d0bf021484c5ec64/mongodb-mms-4.0.7.50349.20190109T1059Z-1.x86_64.rpm',
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
