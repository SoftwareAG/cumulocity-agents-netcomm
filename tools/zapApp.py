#!/usr/bin/python
# -*- coding: utf-8 -*-

import base64, sys, httplib, json, urllib
from random import randint 

from pprint import pprint

# Read commandline arguments

url = str(sys.argv[1])
user = str(sys.argv[2])
password = str(sys.argv[3])
command = str(sys.argv[4])

adminCredentials = 'Basic ' + base64.b64encode('management/' + user + ':'+ password)
client = httplib.HTTPConnection(url)


if command == "list":


	client.request('GET', '/application/applications?pageSize=10000' ,'', {'Authorization': adminCredentials, 'Content-Type': 'application/json', 'Accept': 'application/json'})
	response = client.getresponse()
	responseData = response.read()
	responseStatus = response.status
	client.close()

	if responseStatus == 200:
		responseList = json.loads(responseData)['applications']
		print " "
		print "Application                      | ID       | Type"
		print "---------------------------------|----------|-----------------"
		for iterator in range(0,len(responseList)):
			elem = responseList[iterator]
			aname = elem['name'].encode('utf-8').strip();
			aid = elem['id'].encode('utf-8').strip();
			atype = elem['type'].encode('utf-8').strip();
			aavail = elem['availability'].encode('utf-8').strip();
			print str(aname).ljust(32),"|",str(aid).rjust(5),"|",str(atype),",",str(aavail)
		print " "
	else:
		print "Status: "+str(responseStatus)+" Message: "+str(responseData)


elif (command == "zap") or (command == "probe") or (command == "inventory") or (command == "add"):


	if (command != "inventory"):
		appId = str(sys.argv[5])

	# Get the list of tenants

	client.request('GET', '/tenant/tenants?pageSize=10000' ,'', {'Authorization': adminCredentials, 'Content-Type': 'application/json', 'Accept': 'application/json'})
	response = client.getresponse()
	responseData = response.read()
	client.close()
	responseList = json.loads(responseData)['tenants']
	tenant_list = []
	for iterator in range(0, len(responseList)):
		elem = responseList[iterator]
		tenant_list.append(elem['id'])

	# Now run run through the list of tenants

	for tenant_iter in range(0, len(tenant_list)):
		tenant = tenant_list[tenant_iter]

		if (tenant != "management"):

			# tenant is not management and we check which applications it has

			adminCredentials = 'Basic ' + base64.b64encode('management/' + user + ':'+ password)

			uri='/tenant/tenants/'+tenant+'/applications?pageSize=10000'
			client.request('GET', uri,'', {'Authorization': adminCredentials, 'Content-Type': 'application/json', 'Accept': 'application/json'})
			response = client.getresponse()
			rescode = response.status
			responseData = response.read()
			client.close()
			responseList = json.loads(responseData)['references']
			app_found=0
			if command == "inventory":
				print "Tenant: "+str(tenant)
				print ""
				print "Application                      | ID"
				print "---------------------------------|----------"
				for iterator in range(0, len(responseList)):
					elem = responseList[iterator]['application']
					aid=elem['id']
					aname=elem['name']
					print str(aname).ljust(32),"|",str(aid).rjust(5)
				print ""
			else:
				for iterator in range(0, len(responseList)):
					elem = responseList[iterator]['application']
					if elem['id']==appId:
						app_found=1
			
			if app_found==1:

				# Tenant has the application available


				if command == "zap":
					print "Tenant: "+str(tenant)+" Has application with app ID "+str(appId)+" installed --> Zapping ..."

					adminCredentials = 'Basic ' + base64.b64encode('management/' + user + ':'+ password)

					uri='/tenant/tenants/'+tenant+'/applications/'+appId
					client.request('DELETE', uri,'', {'Authorization': adminCredentials, 'Content-Type': 'application/json', 'Accept': 'application/json'})
					response = client.getresponse()
					zapcode = response.status
					responseData = response.read()
					client.close()
				
					print "Status: "+str(zapcode)+" Result: "+str(responseData)

				else:
					print "Tenant: "+str(tenant)

			else:

				if command == "add":
                                        print "Tenant: "+str(tenant)+" is missing application with app ID "+str(appId)+" installed --> adding ..."
                                        
                                        adminCredentials = 'Basic ' + base64.b64encode('management/' + user + ':'+ password)

                                        uri='/tenant/tenants/'+tenant+'/applications'
					payload='{ "application": { "id" : "'+str(appId)+'"} }'
					print payload
                                        client.request('POST', uri, payload, {'Authorization': adminCredentials, 'Content-Type': 'application/json', 'Accept': 'application/json'})
                                        response = client.getresponse()
                                        zapcode = response.status
                                        responseData = response.read()
                                        client.close()

                                        print "Status: "+str(zapcode)+" Result: "+str(responseData)

else:

	print "Unknown command", command
