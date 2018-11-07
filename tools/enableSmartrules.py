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

adminCredentials = 'Basic ' + base64.b64encode( tenant + '/' + user + ':'+ password)
client = httplib.HTTPConnection(url)


def extract_ct(json):
    try:
        return str(json['creationTime'])
    except KeyError:
        return ""

def getEnabled():
	return {
		"enabled" : "true"
	}


def getDisabled():
	return {
		"enabled" : "false"
	}


dtnow = datetime.datetime.now(pytz.timezone('UTC'))

page=0
pageFault=0

while pageFault == 0:

	page=page+1

	urilink = '/service/smartrule/smartrules?pageSize=2000&currentPage='+str(page)
	client.request('GET', urilink ,'', {'Authorization': adminCredentials, 'Content-Type': 'application/json', 'Accept': 'application/json'})
	response = client.getresponse()
	responseData = response.read()
	client.close()
	responseList = json.loads(responseData)['rules']
	rules_list = []
	for iterator in range(0, len(responseList)):
		elem = responseList[iterator]
		rules_list.append(elem)


	if len(rules_list) < 2000:
                pageFault=1

	# Now run run through the list of tenants
	
	for rules_iter in range(0, len(rules_list)):
		rule = rules_list[rules_iter]
		id = rule['id']
		ruleuri = '/service/smartrule/smartrules/'+str(id)
		print ruleuri
		print json.dumps(rule)

		res = getDisabled()
		client.request('PUT', ruleuri , json.dumps(res), {'Authorization': adminCredentials, 'Content-Type': 'application/json', 'Accept': 'application/json'})	
		response = client.getresponse()
		responseData = response.read()
		client.close()

		
		res = getEnabled()
		client.request('PUT', ruleuri , json.dumps(res), {'Authorization': adminCredentials, 'Content-Type': 'application/json', 'Accept': 'application/json'})	
		response = client.getresponse()
		responseData = response.read()
		client.close()

			
