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
DESCRIPTION = 'Migrate a given device to a new device credential set'

parser = argparse.ArgumentParser(description=DESCRIPTION)

parser.add_argument('host')
parser.add_argument('tenant')
parser.add_argument('username')
parser.add_argument('password')
parser.add_argument('device_id')
parser.add_argument('-V', '--version', action='version', version='%(prog)s ' + VERSION)

args = parser.parse_args()


tenant = args.tenant
url = args.host
user = args.username
password = args.password
oid = args.device_id

adminCredentials = 'Basic ' + base64.b64encode(tenant + '/' + user + ':'+ password)
devCredentials = 'Basic bWFuYWdlbWVudC9kZXZpY2Vib290c3RyYXA6RmhkdDFiYjFm'
client = httplib.HTTPSConnection(url)

def getIdRequest(objectid):
	return {
		"id" : objectid
	}

def getName(json):
	try:
        	return str(json['name'])
    	except KeyError:
        	return ""

def id_generator(size=18, chars=string.ascii_lowercase + string.digits):
	return ''.join(random.choice(chars) for _ in range(size))

def userStruct(name,password):
	return {
		"enabled" : "true",
		"password" : password,
		"userName" : name,
		"sendPasswordResetEmail" : "false",
		"twoFactorAuthenticationEnabled" : "false",
	}

def groupStruct(name,selflink):
	return {
		"user" : {
			"id" : name,
			"self" : selflink
		}
	}

def deviceStruct(user):
	return {
		"owner" : user
	}


# Check for device to be reowned		

urilink = '/inventory/managedObjects/'+str(oid)
client.request('GET', urilink ,'', {'Authorization': adminCredentials, 'Content-Type': 'application/json', 'Accept': 'application/json'})
response = client.getresponse()
rescode = response.status
responseData = response.read()
client.close()

if rescode>299:
	print "ERROR reading target device: "+str(oid)+": "+responseData
	sys.exit(1)

device = json.loads(responseData)
devname = getName(device)

print "Device: "+devname

# Get the devices role id

urilink = '/user/'+str(tenant)+'/groups?pageSize=2000'
client.request('GET', urilink ,'', {'Authorization': adminCredentials, 'Content-Type': 'application/json', 'Accept': 'application/json'})
response = client.getresponse()
rescode = response.status
responseData = response.read()
client.close()

if rescode>299:
	print "ERROR reading groups: "+responseData
	sys.exit(1)

responseList = json.loads(responseData)['groups']                                                                                     
groups_list = []                                                                                                                      
for iterator in range(0, len(responseList)):                                                                                         
	elem = responseList[iterator]                                                                                                
	groups_list.append(elem) 

dgroup=0

for groups_iter in range(0, len(groups_list)):
                group = groups_list[groups_iter]
                gid = group['id']
		name = group['name']

		if name == 'devices':
			dgroup=gid


if dgroup == 0:
	print "ERROR: Cannot find devices group id"
	sys.exit(1)

print "Devices group id: "+str(dgroup)

# Generate device id and password

dev_user = 'device_'+id_generator()
dev_pass = id_generator(20)

print "Generated user and password: "+dev_user+" / "+dev_pass

# create the device user

urilink = '/user/'+str(tenant)+'/users'
payload = userStruct(dev_user,dev_pass)
client.request('POST', urilink ,json.dumps(payload), {'Authorization': adminCredentials, 'Content-Type': 'application/json', 'Accept': 'application/json'})
response = client.getresponse()
rescode = response.status
responseData = response.read()
client.close()

if rescode>299:
	print "ERROR creating user: "+responseData
	sys.exit(1)

userData = json.loads(responseData)
selflink = userData['self']


# add user to the devices group

urilink = '/user/'+str(tenant)+'/groups/'+str(dgroup)+'/users'
payload = groupStruct(dev_user,selflink)
client.request('POST', urilink ,json.dumps(payload), {'Authorization': adminCredentials, 'Content-Type': 'application/json', 'Accept': 'application/json'})
response = client.getresponse()
rescode = response.status
responseData = response.read()
client.close()


if rescode>299:
	print "ERROR adding user to device group: "+str(rescode)+' '+responseData
	sys.exit(1)

# Update the device owner

urilink = '/inventory/managedObjects/'+str(oid)
payload = deviceStruct(dev_user)
client.request('PUT', urilink ,json.dumps(payload), {'Authorization': adminCredentials, 'Content-Type': 'application/json', 'Accept': 'application/json'})
response = client.getresponse()
rescode = response.status
responseData = response.read()
client.close()


if rescode>299:
	print "ERROR changing device owner: "+str(rescode)+' '+responseData
	sys.exit(1)




sys.exit(0)




