name "opsmanager-nonprod"
description "Ops Manager nonprod environment"

cookbook_versions({
'cumulocity'=>'= 9.16.3',
'cumulocity-opsmanager'=>'= 9.16.3'
})

default_attributes(
 "fixhostname" => false,
 "fixhostsfile" => false,
 "useVaults" => false,
)

override_attributes(
  "swapfilesize" => 1024,
  'cumulocity-rsyslog' => {
    'cross-env-log-server' => "cumulocity-multinode-prod",
    'log-server-ext-address' => "monitoring.cumulocity.com"
  },
  'cumulocity-opsmanager' => {
     'mmsGroupId' => '5c00d7f4c8eabe2224af36eb',
     'mmsApiKey' => '5c00e5b1c8eabe2224af9f585c9c0f6b417bc652ba92c898f81bfbb0',
     'mmsBaseUrl' => 'http://ip-172-31-28-30.eu-central-1.compute.internal:8080',
     'mongoUri' => 'mongodb://172.31.28.33:27019,172.31.28.34:27019,172.31.28.35:27019/?maxPoolSize=150&replicaSet=rs09'
  },
  'cumulocity-mongo' => {
     'initRunUser' => 'mongod',
     'initRunGroup' => 'mongod',
  },
  "cumulocity-karaf" => {
    "version" => "9.16.0-1",
  },
)
