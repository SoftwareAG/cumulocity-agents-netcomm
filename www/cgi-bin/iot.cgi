#!/usr/bin/env lua
require('luardb')
require('stringutil')
require('tableutil')

local script_name = os.getenv('SCRIPT_NAME') or 'cumulocity_reregister.lua'
local query_string = os.getenv('QUERY_STRING')


local function cgidecode(str)
	return (str:gsub('+', ' '):gsub("%%(%x%x)", function(xx) return string.char(tonumber(xx, 16)) end))
end


if( os.getenv("SESSION_ID")=="nil" or os.getenv("SESSION_ID") ~=  os.getenv("sessionid") ) then
	return
end

local function send(data)
	io.write('HTTP/1.0 200 OK\n')
	io.write('Content-type: application/javascript\n')
	io.write('Cache-Control: no-cache\n')
	--io.write('Connection: keep-alive\n')
	io.write('Content-Length: '..#data..'\n')
	io.write('\n')
	io.write(data)
end

if query_string=="clearCredentials" then
	luardb.set('service.cumulocity.connection.password', '')
	luardb.set('service.cumulocity.connection.username', '')
	data = '{"ok":true,"error":null}'
else
	data = '{"ok":false,"error":"Unknown operation"}'
end

send(data)
