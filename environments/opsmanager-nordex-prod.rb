# frozen_string_literal: true

name 'opsmanager-nordex-prod'
description 'Ops Manager Nordex prod environment'

cookbook_versions(
  'cumulocity' => '= 9.20.2',
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
    'mmsApiKey' => '5c3ddcd9b324c706823065e0b0e7513f955933445a8496936a5aa935',
    'mmsBaseUrl' => 'http://nxopsprd01v.db.prd.nif.nordex.nexinto.com:8080',
    'mmsGroupId' => '5c3dd187b324c70682305e5a',
    'mongoUri' => 'mongodb://nxopsprd01v.db.prd.nif.nordex.nexinto.com:27019,nxopsprd02v.db.prd.nif.nordex.nexinto.com:27019,nxopsprd03v.db.prd.nif.nordex.nexinto.com:27019/?maxPoolSize=150&replicaSet=rs09'
  },
  'cumulocity-mongo' => {
    'initRunGroup' => 'mongod',
    'initRunUser' => 'mongod',
    'wiredtiger-cache' => 8
  },
  'cumulocity-karaf' => {
    'version' => '9.16.0-1'
  },
)
