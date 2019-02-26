# frozen_string_literal: true

name 'opsmanager-nordex-prod'
description 'Ops Manager Nordex prod environment'

cookbook_versions(
  'cumulocity' => '= 9.20.4',
  'cumulocity-opsmanager' => '= 9.20.3'
)

default_attributes(
  'useVaults' => false,
  'fixhostname' => false,
  'fixhostsfile' => false,
  'swapfilesize' => 0,
  #   'cumulocity-rsyslog' => {
  #     'cross-env-log-server' => 'cumulocity-multinode-prod',
  #     'log-server-ext-address' => 'monitoring.cumulocity.com'
  #   },
  'cumulocity-opsmanager' => {
    # 'appBlock' => '/dev/nvme2n1',
    # 'certificate' => 'opsmanager-internal',
    # 'dataBlock' => '/dev/nvme1n1',
    'mmsApiKey' => '5c516568b324c77c8d1b2090130feec13fa335443427bf6de97aabc3',
    'mmsBaseUrl' => 'http://nxopsprd01v.db.prd.nif.nordex.nexinto.com:8080',
    'mmsGroupId' => '5c5163eeb324c77c8d1b14c0',
    'mongoUri' => 'mongodb://nxopsprd01v.db.prd.nif.nordex.nexinto.com:27019,nxopsprd02v.db.prd.nif.nordex.nexinto.com:27019,nxopsprd03v.db.prd.nif.nordex.nexinto.com:27019/?maxPoolSize=150&replicaSet=rs09',
    'serverPackageUrl' => 'https://s3.amazonaws.com/mongodb-mms-build-onprem/8adb394e6f159f8768805b02d0bf021484c5ec64/mongodb-mms-4.0.7.50349.20190109T1059Z-1.x86_64.rpm',
  },
  'cumulocity-mongo' => {
    'initRunGroup' => 'mongod',
    'initRunUser' => 'mongod',
    'repo-version' => '4.0',
    'wiredtiger-cache' => 8
  },
  'cumulocity-karaf' => {
    'version' => '9.16.0-1'
  }
)
