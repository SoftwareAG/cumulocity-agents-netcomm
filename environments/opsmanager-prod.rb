# frozen_string_literal: true

name 'opsmanager-prod'
description 'Ops Manager prod environment'

cookbook_versions(
  'cumulocity' => '= 9.20.3',
  'cumulocity-opsmanager' => '= 9.20.3'
)

default_attributes(
  'fixhostname' => false,
  'fixhostsfile' => false
)

override_attributes(
  'swapfilesize' => 0,
  'cumulocity-rsyslog' => {
    'cross-env-log-server' => 'cumulocity-multinode-prod',
    'log-server-ext-address' => 'monitoring.cumulocity.com'
  },
  'cumulocity-opsmanager' => {
    'appBlock' => '/dev/nvme2n1',
    'certificate' => 'opsmanager-internal',
    'dataBlock' => '/dev/nvme1n1',
    'mmsApiKey' => '5bd94cfe4352d82ea4167317d849a0fb448c5168721ffae45a248f4f',
    'mmsBaseUrl' => 'http://ip-172-31-10-161.eu-central-1.compute.internal:8080',
    'mmsGroupId' => '5bd94cc14352d82ea41672ce',
    'mongoUri' => 'mongodb://172.31.10.161:27019,172.31.10.163:27019,172.31.10.182:27019/?maxPoolSize=150&replicaSet=rs09'
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
