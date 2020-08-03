require('myrdb')
local timer
local fpath = '/opt/ntcagent/measurementpoll.txt'
local keys = {'service.cumulocity.gpio.interval',
              'service.cumulocity.system_resources.interval',
              'service.cumulocity.signal.interval'}


local function msave(prevs)
   local file = io.open(fpath, 'w')
   if not file then
      srWarning("msave: save setting failed")
      return
   end
   file:write(table.concat(prevs, '\n'))
   file:close()
end


local function mload()
   local prevs = {}
   local file = io.open(fpath)
   if file then
      for line in file:lines() do prevs[#prevs + 1] = line end
      file:close()
      file = io.open(fpath, 'w')
      if file then file:close() end
   end
   for _, line in pairs(prevs) do
      local key, value = string.match(line, '(%S+)%s+(%S+)')
      if key then rdbSet(key, value) end
   end
end


function start(r)
   srInfo("measure poll: freq " .. r:value(4) .. ', duration: ' .. r:value(3))
   local prevs = {}
   for _, key in pairs(keys) do
      prevs[#prevs + 1] = key .. ' ' .. rdbGetStr(key)
      rdbSet(key, r:value(4))
   end
   for i = 1, 3 do
      local key = 'service.cumulocity.gpio.' .. i .. '.notify'
      prevs[#prevs + 1] = key .. ' ' .. rdbGetStr(key)
      rdbSet(key, 'measurement')
   end
   if not timer.isActive then msave(prevs) end
   timer.interval = r:value(3) * 60 * 1000
   timer:start()
   c8y:send('303,' .. r:value(2) .. ',SUCCESSFUL', 1)
end


function stop()
   timer:stop()
   mload()
end


local function getURL(json)
   local urlmatch = '"self":"([%w%.:/-]+/inventory/)%w+/(%d+)"'
   local prefix, id = string.match(json, urlmatch)
   if prefix and id then return prefix .. 'binaries/' .. id end
end


local function dumpRDB(path)
   local file = io.popen('rdb_get -L')
   if not file then return -1 end
   local p = io.open(path, 'w')
   if not p then
      file:close()
      return -1
   end
   for line in file:lines() do p:write(line, '\n') end
   file:close()
   p:close()
   return 0
end


function uploadRDB(r)
   local filepath = '/opt/ntcagent/rdbdump.txt'
   
   if dumpRDB(filepath) ~= 0 then
      c8y:send('304,' .. r:value(2) .. ',"Dump RDB failed"', 1)
      return
   end
   
   c8y:send('303,' .. r:value(2) .. ',EXECUTING')
   if c8y:postf('rdbdump.txt', 'text/plain', filepath) < 0 then
      c8y:send('304,' .. r:value(2) .. ',"Upload RDB failed"', 1)
      return
   end
   
   local url = getURL(c8y.resp)
   if not url then
      c8y:send('304,' .. r:value(2) .. ',"Parse URL failed"', 1)
      return
   end
   
   local name = '"NTC-220 RDB dump"'
   local desc = os.date('"Upload at %x %X"', os.time())
   c8y:send(table.concat({'336', c8y.ID, name, desc, url}, ','), 1)
   c8y:send('303,' .. r:value(2) .. ',SUCCESSFUL', 1)
   
   -- remove tmp file --
   os.remove(filepath);
end


function clearNTPSynchAlarm(r)
   if r:value(3) == 'c8y_NTPSynchAlarm' then
      if rdbGetInt('service.ntp.enable') == 1 and rdbGetStr('system.ntp.time') ~= '' then
         c8y:send('313,' .. r:value(2))
      end
   end
end


function init()
   mload()
   c8y:addMsgHandler(846, 'start')
   c8y:addMsgHandler(850, 'uploadRDB')
   c8y:addMsgHandler(875, 'start')
   c8y:addMsgHandler(877, 'uploadRDB')
   c8y:addMsgHandler(851, 'clearNTPSynchAlarm')
   timer = c8y:addTimer(0, 'stop')
   return 0
end
