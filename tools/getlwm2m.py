#!/usr/bin/python
# -*- coding: utf-8 -*-

import base64, sys, httplib, json, urllib
from random import randint 
import dateutil.parser
import datetime
import pytz

from pprint import pprint

# Read commandline arguments

url = str(sys.argv[1])
tenant = str(sys.argv[2])
user = str(sys.argv[3])
password = str(sys.argv[4])

adminCredentials = 'Basic ' + base64.b64encode(tenant + '/' + user + ':'+ password)
client = httplib.HTTPConnection(url)

def extract_ref(json):
    try:
        return str(json['customProperties']['externalReference'])
    except KeyError:
        return ""

def extract_ct(json):
    try:
        return str(json['creationTime'])
    except KeyError:
        return ""


page=0
pageFault=0

while pageFault == 0:

        page=page+1

        urilink = '/inventory/managedObjects?type=c8y_lwm2m&pageSize=2000&currentPage='+str(page)
        client.request('GET', urilink ,'', {'Authorization': adminCredentials, 'Content-Type': 'application/json', 'Accept': 'application/json'})
        response = client.getresponse()
        responseData = response.read()
        client.close()

        responseList = json.loads(responseData)['managedObjects']
        tenant_list = []
        for iterator in range(0, len(responseList)):
                elem = responseList[iterator]
                tenant_list.append(elem)


        if len(tenant_list) < 2000:
                pageFault=1

        # Now run run through the list of tenants

        for tenant_iter in range(0, len(tenant_list)):
                tenant = tenant_list[tenant_iter]

                tid = str(tenant['id'])
                tname = str(tenant['name'])

                #print tid+';'+tname
                print tid


