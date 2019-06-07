import argparse
import requests
import json
from requests.auth import HTTPBasicAuth

VERSION = '1.0.0'
DESCRIPTION = 'Transfer data form one device to another'

parser = argparse.ArgumentParser(description=DESCRIPTION)

parser.add_argument('host')
parser.add_argument('tenant')
parser.add_argument('username')
parser.add_argument('password')
parser.add_argument('device_id')
parser.add_argument('--new_tenant', dest='new_tenant')
parser.add_argument('--new_username', dest='new_username')
parser.add_argument('--new_password', dest='new_password')
parser.add_argument('--ssl', dest="ssl", action="store_true", default=False)
parser.add_argument('--new_platform_host', dest="new_platform_host")
parser.add_argument('--new_platform_ssl', dest="new_platform_ssl", action="store_true", default=False)
parser.add_argument('--device_only', dest='device_only', action='store_true', default=False)
parser.add_argument('--data_only', dest='data_only', action='store_true', default=False)
parser.add_argument('--new_device_id', dest='new_device_id')
parser.add_argument('-v', '--verbose', dest='v', action='store_true', default=False)
parser.add_argument('-V', '--version', action='version', version='%(prog)s ' + VERSION)

args = parser.parse_args()

TIMEOUT = 10
PAGE_SIZE = 100
MEASUREMENTS_RESOURCE_PATH = '/measurement/measurements'
MEASUREMENTS_RESOURCE_NAME = 'measurements'
MEASUREMENT_RESOURCE_NAME = 'measurement'
EVENTS_RESOURCE_PATH = '/event/events'
EVENTS_RESOURCE_NAME = 'events'
EVENT_RESOURCE_NAME = 'event'
ALARMS_RESOURCE_PATH = '/alarm/alarms'
ALARMS_RESOURCE_NAME = 'alarms'
ALARM_RESOURCE_NAME = 'alarm'

HEADERS = {'accept': 'application/json'}
LINK_HEADER = {'accept': 'application/vnd.com.nsn.cumulocity.managedObject+json'}


class DeviceOperationResponse:
    def __init__(self, successful, description, device):
        self.successful = successful
        self.description = description
        self.device = device

    def have_children(self):
        return True if self.device['childDevices']['references'] else False

    def get_children(self):
        return self.device['childDevices']['references']


class GetOperationResponse:
    def __init__(self, successful, description, payload):
        self.successful = successful
        self.description = description
        self.payload = payload


class TransferStatus:
    def __init__(self, successful, unsuccessful, can_be_more):
        self.successful = successful
        self.unsuccessful = unsuccessful
        self.can_be_more = can_be_more


class LinkStatus:
    def __init__(self, successful, description):
        self.successful = successful
        self.description = description


def get_protocol():
    protocol = 'http://'
    if args.ssl:
        protocol = 'https://'

    return protocol


def get_upload_protocol():
    if not args.new_platform_host:
        return get_protocol()

    protocol = 'http://'
    if args.new_platform_ssl:
        protocol = 'https://'

    return protocol


def get_upload_host():
    if not args.new_platform_host:
        return args.host

    return args.new_platform_host


def get_upload_tenant():
    if not args.new_tenant:
        return args.tenant

    return args.new_tenant


def get_upload_username():
    if not args.new_username:
        return args.username

    return args.new_username


def get_upload_password():
    if not args.new_password:
        return args.password

    return args.new_password


def get_device(device_id, form_target_platform):
    if form_target_platform:
        protocol = get_upload_protocol()
        host = get_upload_host()
        auth = HTTPBasicAuth(get_upload_tenant() + '/' + get_upload_username(), get_upload_password())
    else:
        protocol = get_protocol()
        host = args.host
        auth = HTTPBasicAuth(args.tenant + '/' + args.username, args.password)

    url = '{}{}/inventory/managedObjects/{}'.format(protocol, host, device_id)

    try:
        resp = requests.get(url,
                            auth=auth,
                            headers=HEADERS,
                            timeout=TIMEOUT)
    except Exception as e:
        successful = False
        description = e.message
        device = {}
    else:
        successful = resp.status_code == 200
        description = ''
        if not successful:
            description = 'status code:{} response:{}'.format(resp.status_code, resp.json())
            device = {}
        else:
            print resp.json()
            device = resp.json()

    return DeviceOperationResponse(successful, description, device)


def prepare_device_for_create(device):
    del device['id']
    del device['lastUpdated']
    del device['childDevices']
    del device['childAssets']
    del device['childAdditions']
    del device['deviceParents']
    del device['assetParents']
    del device['additionParents']
    del device['owner']
    if "self" in device:
        del device["self"]


def create_device(device):
    try:
        resp = requests.post(get_upload_protocol() + get_upload_host() + '/inventory/managedObjects',
                             auth=HTTPBasicAuth(get_upload_tenant() + '/' + get_upload_username(),
                                                get_upload_password()),
                             data=json.dumps(device), headers=HEADERS, timeout=TIMEOUT)
    except Exception as e:
        successful = False
        description = e.message
        device = {}
    else:
        successful = resp.status_code / 100 == 2
        description = ''
        if not successful:
            try:
                description = 'status code:{} response:{}'.format(resp.status_code, resp.json())
            except ValueError as v:
                description = 'status code:{}'.format(resp.status_code, resp.text)
            device = {}
        else:
            device = resp.json()

    return DeviceOperationResponse(successful, description, device)


def link_parent_to_child(parent_id, child_id):
    child = {parent_id: child_id}
    try:
        put_children_resp = requests.post(
            get_upload_protocol() + get_upload_host() + '/inventory/managedObjects/' + str(parent_id) + '/childDevices',
            auth=HTTPBasicAuth(get_upload_tenant() + '/' + get_upload_username(), get_upload_password()),
            data=json.dumps(child), headers=LINK_HEADER, timeout=TIMEOUT)
    except Exception as e:
        successful = False
        description = e.message
    else:
        successful = put_children_resp.status_code / 100 == 2
        description = ''
        if not successful:
            description = 'status code:{} resp:{}'.format(put_children_resp.status_code, put_children_resp.json())

    return LinkStatus(successful, description)


def get_device_resources(resource_path, page_no, device_id):
    url = '{}{}{}?source={}&pageSize={}&currentPage={}'.format(get_protocol(), args.host, resource_path,
                                                               device_id,
                                                               PAGE_SIZE, page_no)
    try:
        resp = requests.get(url, auth=HTTPBasicAuth(args.tenant + '/' + args.username, args.password), timeout=TIMEOUT)
    except Exception as e:
        successful = False
        description = e.message
        payload = []
    else:
        successful = resp.status_code / 100 == 2
        description = ''
        if not successful:
            description = 'status code:{} response:{}'.format(resp.status_code, resp.json())
            payload = []
        else:
            payload = resp.json()

    return GetOperationResponse(successful, description, payload)


def get_device_measurements(page_no, device_id):
    return get_device_resources(MEASUREMENTS_RESOURCE_PATH, page_no, device_id)


def get_device_events(page_no, device_id):
    return get_device_resources(EVENTS_RESOURCE_PATH, page_no, device_id)


def get_device_alarms(page_no, device_id):
    return get_device_resources(ALARMS_RESOURCE_PATH, page_no, device_id)


def upload_device_resource(resource_path, resource):
    url = '{}{}{}'.format(get_upload_protocol(), get_upload_host(), resource_path)
    try:
        resp = requests.post(url,
                             auth=HTTPBasicAuth(get_upload_tenant() + '/' + get_upload_username(),
                                                get_upload_password()),
                             data=json.dumps(resource), headers=HEADERS, timeout=TIMEOUT)
    except Exception as e:
        successful = False
        description = e.message
        payload = []
    else:
        successful = resp.status_code / 100 == 2
        description = ''
        if not successful:
            description = 'status code:{} response:{}'.format(resp.status_code, resp.json())
            payload = []
        else:
            payload = resp.json()

    return GetOperationResponse(successful, description, payload)


def upload_device_measurement(measurement):
    return upload_device_resource(MEASUREMENTS_RESOURCE_PATH, measurement)


def upload_device_event(event):
    return upload_device_resource(EVENTS_RESOURCE_PATH, event)


def upload_device_alarm(alarm):
    return upload_device_resource(ALARMS_RESOURCE_PATH, alarm)


def prepare_resource_for_create(new_device_id, resource, delete_creation_time):
    resource['source']['id'] = new_device_id
    del resource['id']
    if resource['self']:
        del resource['self']
    if resource['source']['self']:
        del resource['source']['self']
    if delete_creation_time:
        del resource['creationTime']


def transfer_resources_page(get_page_function, upload_resource_function, resources_name, resource_name,
                            delete_creation_time, page_no, device_id, new_device_id):
    resources = get_page_function(page_no, device_id)

    if not resources.successful:
        print 'Error while getting {} form original device: {}'.format(resources_name, resources.description)
        return TransferStatus([], [], False)

    if 'totlaPages' in resources.payload['statistics']:
        total_pages = resources.payload['statistics']['totalPages']
        total_pages = total_pages if total_pages else 0
        can_bo_more = total_pages > page_no
    else:
        can_bo_more = len(resources.payload[resources_name]) == PAGE_SIZE

    resources_payload = resources.payload[resources_name]

    successful = []
    unsuccessful = []
    for resource in resources_payload:
        old_id = resource['id']
        prepare_resource_for_create(new_device_id, resource, delete_creation_time)
        upload = upload_resource_function(resource)
        if not upload.successful:
            unsuccessful.append(
                '{} with id:{} transfer failed due to:{}'.format(resource_name, old_id, upload.description))
        else:
            successful.append('Successfully transferred {} with id:{} new id:{}'.format(resource_name, old_id,
                                                                                        upload.payload['id']))

    return TransferStatus(successful, unsuccessful, can_bo_more)


def transfer_measurements_page(page_no, device_id, new_device_id):
    return transfer_resources_page(get_device_measurements, upload_device_measurement, MEASUREMENTS_RESOURCE_NAME,
                                   MEASUREMENT_RESOURCE_NAME, False, page_no, device_id, new_device_id)


def transfer_events_page(page_no, device_id, new_device_id):
    return transfer_resources_page(get_device_events, upload_device_event, EVENTS_RESOURCE_NAME, EVENT_RESOURCE_NAME,
                                   True, page_no, device_id, new_device_id)


def transfer_alarms_page(page_no, device_id, new_device_id):
    return transfer_resources_page(get_device_alarms, upload_device_alarm, ALARMS_RESOURCE_NAME, ALARM_RESOURCE_NAME,
                                   True, page_no, device_id, new_device_id)


def display_transfer_results(transfer_result, device_id, new_device_id, resources_name):
    print 'Successfully transferred {} for device {} to device {}'.format(resources_name, device_id, new_device_id)
    for successful in transfer_result.successful:
        print successful

    print 'Unsuccessfully transferred {} for device{} to device {}'.format(resources_name, device_id, new_device_id)
    for unsuccessful in transfer_result.unsuccessful:
        print unsuccessful


def transfer_device_resources(transfer_page_function, device_id, new_device_id, resources_name):
    page_no = 1

    transfer_page = transfer_page_function(page_no, device_id, new_device_id)
    if args.v:
        display_transfer_results(transfer_page, device_id, new_device_id, resources_name)

    while transfer_page.can_be_more:
        page_no = page_no + 1
        transfer_page = transfer_page_function(page_no, device_id, new_device_id)
        if args.v:
            display_transfer_results(transfer_page, device_id, new_device_id, resources_name)


def transfer_device_measurements(device_id, new_device_id):
    transfer_device_resources(transfer_measurements_page, device_id, new_device_id, MEASUREMENTS_RESOURCE_NAME)


def transfer_device_events(device_id, new_device_id):
    transfer_device_resources(transfer_events_page, device_id, new_device_id, EVENTS_RESOURCE_NAME)


def transfer_device_alarms(device_id, new_device_id):
    transfer_device_resources(transfer_alarms_page, device_id, new_device_id, ALARMS_RESOURCE_NAME)


def get_device_with_children(device_id, from_target_platform):
    children = []

    get_device_resp = get_device(device_id, from_target_platform)

    if not get_device_resp.successful:
        print 'Device with id:{} receiving error:{}'.format(device_id, get_device_resp.description)
        return DeviceOperationResponse(False, 'Receive error:{}'.format(get_device_resp.description), {}), None

    if get_device_resp.have_children():
        for child in get_device_resp.get_children():
            print child
            resp = transfer_device_with_data(child['managedObject']['id'])
            if resp.successful:
                children.append(resp.device)

    return DeviceOperationResponse(True, '', get_device_resp.device), children


def transfer_device(device_id, device, children):
    prepare_device_for_create(device)
    create_resp = create_device(device)

    if not create_resp.successful:
        print 'Failed to create device with id:{} {}'.format(device_id, create_resp.description)
        return DeviceOperationResponse(False, 'Create error:{}'.format(create_resp.description), {})

    print 'Device with original id:{} created with id:{}'.format(device_id, create_resp.device['id'])

    for child in children:
        link = link_parent_to_child(int(create_resp.device['id']), int(child['id']))
        if not link.successful:
            print "Failed to create link between parent with id:{}, and child with id:{} {}".format(
                create_resp.device['id'], int(child['id']), link.description)

    return create_resp


def transfer_data(device_id, new_device_id):
    transfer_device_measurements(device_id, new_device_id)
    transfer_device_events(device_id, new_device_id)
    transfer_device_alarms(device_id, new_device_id)


def transfer_device_with_data(device_id):
    get_device_resp, children = get_device_with_children(device_id, False)
    if not get_device_resp.successful:
        return get_device_resp

    device = get_device_resp.device
    children = [{'id': child['id']} for child in children]

    create_resp = transfer_device(device_id, device, children)
    if not create_resp.successful:
        return create_resp

    new_device_id = create_resp.device['id']

    if not args.device_only:
        transfer_data(device_id, new_device_id)

    return DeviceOperationResponse(True, '', create_resp.device)


def transfer_data_only(device_id, new_device_id):
    get_device_resp, children = get_device_with_children(device_id, False)
    if not get_device_resp.successful:
        return get_device_resp

    children = [{'id': child['id'], 'name': child['name']} for child in children]

    get_target_device_resp, target_children = get_device_with_children(new_device_id, True)
    if not get_target_device_resp.successful:
        return get_target_device_resp

    target_children = [{'id': child['id'], 'name': child['name']} for child in target_children]

    id_pairs = []
    for child in children:
        for target_child in target_children:
            if child['name'] == target_child['name']:
                id_pairs.append([child['id'], target_child['id']])

    for id_pair in id_pairs:
        transfer_data_only(id_pair[0], id_pair[1])

    transfer_data(device_id, new_device_id)


print args.device_id
if not args.data_only:
    transfer_device_with_data(args.device_id)
else:
    transfer_data_only(args.device_id, args.new_device_id)

