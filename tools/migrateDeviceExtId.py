#!/usr/bin/python
# -*- coding: utf-8 -*-

import base64, sys, httplib, json, urllib
from random import randint 
import dateutil.parser
import datetime
import pytz
import argparse
import string, random

from pprint import pprint

# Read commandline arguments

VERSION = '1.0.0'
DESCRIPTION = 'Migrate a given device external id to a new device set'

parser = argparse.ArgumentParser(description=DESCRIPTION)

parser.add_argument('host')
parser.add_argument('tenant')
parser.add_argument('username')
parser.add_argument('password')
parser.add_argument('device_id')
parser.add_argument('target_host')
parser.add_argument('target_tenant')
parser.add_argument('target_user')
parser.add_argument('target_password')
parser.add_argument('target_id')
parser.add_argument('--ssl', dest="ssl", action="store_true", default=False)
parser.add_argument('--trg_ssl', dest="trg_ssl", action="store_true", default=False)
parser.add_argument('-V', '--version', action='version', version='%(prog)s ' + VERSION)

args = parser.parse_args()


tenant = args.tenant
url = args.host
user = args.username
password = args.password
oid = args.device_id
trg_tenant = args.target_tenant
trg_url = args.target_host
trg_user = args.target_user
trg_password = args.target_password
trg_oid = args.target_id

def gettype(json):
        try:
                return str(json['type'])
        except KeyError:
                return ""

def getid(json):
        try:
                return str(json['externalId'])
        except KeyError:
                return ""

def getidstruct(idtype,idname):
	return {
		'externalId' : idname,
		'type' : idtype
	}


adminCredentials = 'Basic ' + base64.b64encode(tenant + '/' + user + ':'+ password)
trgCredentials = 'Basic ' + base64.b64encode(trg_tenant + '/' + trg_user + ':'+ trg_password)
if args.ssl: 
	client = httplib.HTTPSConnection(url)
else:
	client = httplib.HTTPConnection(url)

if args.trg_ssl:
	trgclient = httplib.HTTPSConnection(trg_url)
else:
	trgclient = httplib.HTTPConnection(trg_url)


# Check for external ID		

urilink = '/identity/globalIds/'+str(oid)+'/externalIds?pageSize=2000'
client.request('GET', urilink ,'', {'Authorization': adminCredentials, 'Content-Type': 'application/json', 'Accept': 'application/json'})
response = client.getresponse()
rescode = response.status
responseData = response.read()
client.close()

if rescode>299:
	print "ERROR reading globalID for device: "+str(oid)+": "+responseData
	sys.exit(1)

ids = json.loads(responseData)['externalIds']

for groups_iter in range(0, len(ids)):
                device = ids[groups_iter]
		idtype = gettype(device)
		idval = getid(device)
		print idtype, idval

		trglink = '/identity/globalIds/'+str(trg_oid)+'/externalIds'
		payload = json.dumps(getidstruct(idtype,idval))
		trgclient.request('POST', trglink, payload, {'Authorization': trgCredentials, 'Content-Type': 'application/json', 'Accept': 'application/json'})

		trgresponse = trgclient.getresponse()
		trgrescode = trgresponse.status
		trgdata = trgresponse.read()
		trgclient.close()

		if trgrescode > 299:
			print "ERROR writing external ID for device: "+str(trg_oid)+": "+trgdata
			sys.exit(1)

		print "Written externalID for device "+str(trg_oid)+": "+trgdata

sys.exit(0)




