#!/usr/bin/env python
# -*- coding: utf-8 -*-
import requests, base64, urlparse, datetime, operator, tabulate

productionUrl = 'localhost:8111'
productionUser = 'cep'
productionPassword = 'Toymr1fds'

lastXHours = 1

engineMetricType = 'c8y_EngineMetric'
statementMetricType = 'c8y_StatementMetric'

url = 'http://' + productionUrl
querystringEngine = {
  "dateTo": datetime.datetime.utcnow().strftime("%Y-%m-%dT%H:%M:%S+00:00"),
  "pageSize": "2000",
  "currentPage": "1",
  "type": engineMetricType,
  "dateFrom": (datetime.datetime.utcnow() - datetime.timedelta(hours=lastXHours)).strftime("%Y-%m-%dT%H:%M:%S+00:00")
}
querystringStatement = {
  "dateTo": datetime.datetime.utcnow().strftime("%Y-%m-%dT%H:%M:%S+00:00"),
  "pageSize": "2000",
  "currentPage": "1",
  "type": statementMetricType,
  "dateFrom": (datetime.datetime.utcnow() - datetime.timedelta(hours=lastXHours)).strftime("%Y-%m-%dT%H:%M:%S+00:00")
}
headers = {'authorization': 'Basic ' + base64.b64encode('management/' + productionUser +':'+ productionPassword)}


def extract_input_count(json):
    try:
        return int(json['c8y_EngineMetric']['inputCount']['value'])
    except KeyError:
        return 0

def extract_statements(json):
    try:
        return int(json['c8y_EngineMetric']['statements']['value'])
    except KeyError:
        return 0

def extract_depth(json):
    try:
        return int(json['c8y_EngineMetric']['scheduleDepth']['value'])
    except KeyError:
        return 0

def getTenantName(source):
  response = requests.request("GET", url + '/inventory/managedObjects/' + str(source), headers=headers)
  return response.json()['name'].split(' ')[-1]


currentMeasurements = 0
totalMeasurements = []


# Look for tenants with a lot of statements triggered

while querystringEngine is not None:
  response = requests.request("GET", url + '/measurement/measurements', headers=headers, params=querystringEngine)
  content = response.json()
  currentMeasurements = len(content['measurements'])
  if currentMeasurements > 0 and 'next' in content:
    totalMeasurements = totalMeasurements + content['measurements']
    querystringEngine = dict(urlparse.parse_qsl(urlparse.urlsplit(content['next']).query))
  else:
    querystringEngine = None

print 'Total tenants with engine metric: ' + str(len(totalMeasurements))

totalMeasurements.sort(key=extract_input_count, reverse=True)

tenantStatistics = []
print 'Most inputs per tenants last hour:'
for i in range(0,10):
  try:
    tenantStatistics.append([getTenantName(totalMeasurements[i]['source']['id']), totalMeasurements[i]['c8y_EngineMetric']['inputCount']['value']])
  except IndexError:
    break

print tabulate.tabulate(tenantStatistics, headers=['Tenant', 'Input Count'])
print

totalMeasurements.sort(key=extract_statements, reverse=True)

tenantStatistics = []
print 'Most statements deployed last hour:'
for i in range(0,10):
  try:
    tenantStatistics.append([getTenantName(totalMeasurements[i]['source']['id']), totalMeasurements[i]['c8y_EngineMetric']['statements']['value']])
  except IndexError:
    break

print tabulate.tabulate(tenantStatistics, headers=['Tenant', 'Statements'])
print

totalMeasurements.sort(key=extract_depth, reverse=True)

tenantStatistics = []
print 'Highest Schedule Depth last hour:'
for i in range(0,10):
  try:
    tenantStatistics.append([getTenantName(totalMeasurements[i]['source']['id']), totalMeasurements[i]['c8y_EngineMetric']['scheduleDepth']['value']])
  except IndexError:
    break

print tabulate.tabulate(tenantStatistics, headers=['Tenant', 'Schedule Depth'])
print

# Look for most CPU time statements

while querystringStatement is not None:
  response = requests.request("GET", url + '/measurement/measurements', headers=headers, params=querystringStatement)
  content = response.json()
  currentMeasurements = len(content['measurements'])
  if currentMeasurements > 0 and 'next' in content:
    totalMeasurements = totalMeasurements + content['measurements']
    querystringStatement = dict(urlparse.parse_qsl(urlparse.urlsplit(content['next']).query))
  else:
    querystringStatement = None

statementMetrics = []

for m in totalMeasurements:
  for key in m.keys():
    if isinstance(m[key], dict) and 'inputs' in m[key].keys():
      metric = {
        'fragment': key,
        'source': m['source']['id'],
        'inputs': m[key]['inputs']['value'],
        'outputsRemove': m[key]['outputsRemove']['value'],
        'outputsInput': m[key]['outputsInput']['value'],
        'cpuTime': m[key]['cpuTime']['value'],
        'wallTime': m[key]['wallTime']['value']
      }
      statementMetrics.append(metric)

print 'Total statements analysed within last hour: ' + str(len(statementMetrics))
print

statementMetrics = sorted(statementMetrics, key=lambda k: (-long(k['cpuTime'])))

tenantStatistics = []
print 'Statements with most CPU time'
for i in range(0,25):
  try:
    tenantStatistics.append([getTenantName(statementMetrics[i]['source']), statementMetrics[i]['fragment'], statementMetrics[i]['cpuTime']])
  except IndexError:
    break

print tabulate.tabulate(tenantStatistics, headers=['Tenant', 'Statement', 'CPU Time (ns)'])
print

statementMetrics = sorted(statementMetrics, key=lambda k: (-long(k['wallTime'])))

tenantStatistics = []
print 'Statements with most Wall time'
for i in range(0,25):
  try:
    tenantStatistics.append([getTenantName(statementMetrics[i]['source']), statementMetrics[i]['fragment'], statementMetrics[i]['wallTime']])
  except IndexError:
    break

print tabulate.tabulate(tenantStatistics, headers=['Tenant', 'Statement', 'CPU Time (ns)'])
print

statementMetrics = sorted(statementMetrics, key=lambda k: (-long(k['inputs'])))

tenantStatistics = []
print 'Statements with most Inputs'
for i in range(0,25):
  try:
    tenantStatistics.append([getTenantName(statementMetrics[i]['source']), statementMetrics[i]['fragment'], statementMetrics[i]['inputs']])
  except IndexError:
    break

print tabulate.tabulate(tenantStatistics, headers=['Tenant', 'Statement', 'Inputs'])
print
