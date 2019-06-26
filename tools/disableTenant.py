#!/usr/bin/python
# -*- coding: utf-8 -*-

import base64, sys, httplib, json, urllib, time
from random import randint 
from time import gmtime, strftime

from pprint import pprint

# Read commandline arguments

url = str(sys.argv[1])
user = str(sys.argv[2])
password = str(sys.argv[3])
tenant = str(sys.argv[4])

dateNow = time.time() 

adminCredentials = 'Basic ' + base64.b64encode('management/' + user + ':'+ password)
client = httplib.HTTPConnection(url)


payLoad = {
		"status" : "SUSPENDED"
	  }



client.request('PUT', '/tenant/tenants/'+tenant ,json.dumps(payLoad), {'Authorization': adminCredentials, 'Content-Type': 'application/json', 'Accept': 'application/json'})
response = client.getresponse()
responseData = response.read()
responseStatus = response.status
client.close()


responseItem = json.loads(responseData)


print "Tenant: "+str(tenant)+" Status: "+str(responseStatus)

if responseStatus > 299:
	print "Message: "+str(responseData)
