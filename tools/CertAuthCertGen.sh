#!/bin/bash

environment="$1"
if [[ -z $environment ]] ; then
  environment="$( awk '/Environment/ {print $2}' /etc/motd )"
fi

opensslConf="$( cat << EOF
HOME			= .
RANDFILE		= \$ENV::HOME/.rnd
oid_section		= new_oids
[ new_oids ]
tsa_policy1 = 1.2.3.4.1
tsa_policy2 = 1.2.3.4.5.6
tsa_policy3 = 1.2.3.4.5.7
[ ca ]
default_ca	= CA_default
[ CA_default ]
dir		= /etc/pki/CA
certs		= \$dir/certs
crl_dir		= \$dir/crl
database	= \$dir/index.txt
new_certs_dir	= \$dir/newcerts
certificate	= \$dir/cacert.pem
serial		= \$dir/serial
crlnumber	= \$dir/crlnumber
crl		= \$dir/crl.pem
private_key	= \$dir/private/cakey.pem
RANDFILE	= \$dir/private/.rand
x509_extensions	= usr_cert
name_opt 	= ca_default
cert_opt 	= ca_default
copy_extensions = copy
default_days	= 3650
default_crl_days= 30
default_md	= sha256
preserve	= no
policy		= policy_match
[ policy_match ]
countryName		= match
stateOrProvinceName	= match
organizationName	= match
organizationalUnitName	= optional
commonName		= supplied
emailAddress		= optional
[ policy_anything ]
countryName		= optional
stateOrProvinceName	= optional
localityName		= optional
organizationName	= optional
organizationalUnitName	= optional
commonName		= supplied
emailAddress		= optional
[ req ]
prompt			= no
default_bits		= 2048
default_md		= sha256
default_keyfile 	= privkey.pem
distinguished_name	= req_distinguished_name
attributes		= req_attributes
x509_extensions	= v3_ca
string_mask = utf8only
req_extensions = v3_req
[ req_distinguished_name ]
countryName                     = DE
stateOrProvinceName             = NRW
localityName                    = Duesseldorf
0.organizationName              = Cumulocity GmbH
organizationalUnitName          = Organizational Unit Name (eg, section)
commonName                      = ${environment}
emailAddress                    = support@cumulocity.com

#countryName                     = Country Name (2 letter code)
#countryName_default             = XX
#countryName_min                 = 2
#countryName_max                 = 2
#stateOrProvinceName             = State or Province Name (full name)
#localityName                    = Locality Name (eg, city)
#localityName_default            = Default City
#0.organizationName              = Organization Name (eg, company)
#0.organizationName_default      = Default Company Ltd
#organizationalUnitName          = Organizational Unit Name (eg, section)
#commonName                      = Common Name (eg, your name or your server\'s hostname)
#commonName_max                  = 64
#emailAddress                    = Email Address
#emailAddress_max                = 64
[ req_attributes ]
challengePassword		= A challenge password
challengePassword_min		= 4
challengePassword_max		= 20
unstructuredName		= An optional company name
[ usr_cert ]
basicConstraints		= CA:FALSE
nsComment			= "OpenSSL Generated Certificate"
subjectKeyIdentifier		= hash
authorityKeyIdentifier		= keyid,issuer
subjectAltName 			= email:copy
[ v3_req ]
basicConstraints = CA:FALSE
keyUsage = nonRepudiation, digitalSignature, keyEncipherment
subjectAltName = email:move
[ alt_names ]
[ v3_ca ]
subjectKeyIdentifier		= hash
authorityKeyIdentifier		= keyid:always,issuer
basicConstraints = critical, CA:TRUE, pathlen:3
keyUsage = critical, cRLSign, keyCertSign
nsCertType = sslCA, emailCA
subjectAltName			= email:copy
[ crl_ext ]
authorityKeyIdentifier		= keyid:always
[ proxy_cert_ext ]
basicConstraints		= CA:FALSE
nsComment			= "OpenSSL Generated Certificate"
subjectKeyIdentifier		= hash
authorityKeyIdentifier		= keyid,issuer
proxyCertInfo			= critical,language:id-ppl-anyLanguage,pathlen:3,policy:foo
[ tsa ]
default_tsa = tsa_config1
[ tsa_config1 ]
dir		= ./demoCA
serial		= \$dir/tsaserial
crypto_device	= builtin
signer_cert	= \$dir/tsacert.pem
certs		= \$dir/cacert.pem
signer_key	= \$dir/private/tsakey.pem
default_policy	= tsa_policy1
other_policies	= tsa_policy2, tsa_policy3
digests		= sha1, sha256, sha384, sha512
accuracy	= secs:1, millisecs:500, microsecs:100
clock_precision_digits  = 0
ordering		= yes
tsa_name		= yes
ess_cert_id_chain	= no
EOF
)"

openssl genrsa -out "${environment}-ca.key" 2048
key="$( sed ':a;N;$!ba;s/\n/\\n/g' "${environment}-ca.key" )"
openssl req -new -key "${environment}-ca.key" -x509 -extensions v3_ca -config <( cat <<< "${opensslConf}" ) -out "${environment}-ca.pem"
cert="$( sed ':a;N;$!ba;s/\n/\\n/g' "${environment}-ca.pem" )"

echo '{' > "${environment}-ca.json"
echo '	"id" : "'${environment}-ca'",' >> "${environment}-ca.json"
echo '	"key" : "'"${key}"'\n",' >> "${environment}-ca.json"
echo '	"cert" : "'"${cert}"'\n"' >> "${environment}-ca.json"
echo '}' >> "${environment}-ca.json"


chmod go= "${environment}-ca."*

