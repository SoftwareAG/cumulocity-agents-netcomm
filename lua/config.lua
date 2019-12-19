require('myrdb')
local keyUser = 'service.cumulocity.connection.username'
local keyPass = 'service.cumulocity.connection.password'
local keyRd = 'service.cumulocity.modbus.readonly'
local opid
local p = '/opt/cdcs/upload/ntc_6200.cfg.tar.gz'
local fpath = '/opt/ntcagent/config.txt'
local savefile = '/opt/ntcagent/config.save'
local fname = 'ntc_6200.cfg.tar.gz'
local vpncmd = 'tar -C /usr/local/cdcs -zcf - ipsec.d openvpn-keys ssh-hostkeys | openssl des3 -salt -k "$pw" | dd of=/tmp/vpn.des3'
local tarcmd = 'cd /tmp && tar -zcf ' .. fname .. ' ntc_6200.cfg vpn.des3'

local function _predConfig(entry)
   return string.match(entry, keyUser) or string.match(entry, keyPass) or
      string.match(entry, keyRd)
end


local function _presaveConfig()
   local file = io.open(savefile, 'w')
   if file then
      file:write(keyUser .. ' ' .. rdbGetStr(keyUser) .. '\n')
      file:write(keyPass .. ' ' .. rdbGetStr(keyPass) .. '\n')
      file:write(keyRd .. ' ' .. rdbGetStr(keyRd))
      file:close()
   end
end


local function _getConfig()
   local file = io.popen('dbcfg_export -p "$pw"')
   if not file then return nil end
   local tbl = {}
   for line in file:lines() do
      if not _predConfig(line) then tbl[#tbl + 1] = line end
   end
   file:close()
   return tbl
end


local function _saveOp(id)
   local file = io.open(fpath, 'w')
   if not file then
      srWarning('open config.txt failed')
   else
      file:write(id)
      file:close()
   end
end


local function _loadOp()
   local file = io.open(fpath)
   if file then
      local id = file:read('*n')
      file:close()
      os.remove(fpath)
      return id
   end
end


function updateConfig(r)
   local file = io.open('/tmp/ntc_6200.cfg', 'w')
   if not file then
      c8y:send('304,' .. r:value(2) .. ',"write config failed"', 1)
      return
   end
   c8y:send('303,' .. r:value(2) .. ',EXECUTING')
   file:write(r:value(3))
   file:close()
   _presaveConfig()
   os.execute(vpncmd)
   os.execute(tarcmd)
   os.execute('mv /tmp/ntc_6200.cfg.tar.gz ' .. p)
   if not os.execute('install_file ' .. p) then
      c8y:send('304,' .. r:value(2) .. ',"Update config failed"', 1)
      return
   end
   _saveOp(r:value(2))
   rdbSet('service.system.reset', '1')
end


function sendConfig(r)
   local tbl = _getConfig()
   if not tbl then
      c8y:send('304,' .. r:value(2) .. ',"Export config failed"', 1)
      return
   end
   local value = '"' .. table.concat(tbl, '\\n') .. '"'
   if http:post(table.concat({'316', c8y.ID, value}, ',')) then
      c8y:send('303,' .. r:value(2) .. ',SUCCESSFUL', 1)
   end
end


local function _getURL(json)
   local urlmatch = '"self":"([%w%.:/-]+/inventory/)%w+/(%d+)"'
   local prefix, id = string.match(json, urlmatch)
   if prefix and id then return prefix .. 'binaries/' .. id end
end


function uploadConfig(r)
   local tbl = _getConfig()
   if not tbl then
      c8y:send('304,' .. r:value(2) .. ',"Export config failed"', 1)
      return
   end
   c8y:send('303,' .. r:value(2) .. ',EXECUTING')
   local file = io.open('/tmp/ntc_6200.cfg', 'w')
   if not file then
      c8y:send('304,' .. r:value(2) .. ',"Write config failed"', 1)
      return
   end
   file:write(table.concat(tbl, '\n'))
   file:close()
   os.execute(vpncmd)
   os.execute(tarcmd)
   if c8y:postf(fname, 'text/plain', '/tmp/' .. fname) < 0 then
      c8y:send('304,' .. r:value(2) .. ',"Post config failed"', 1)
      return
   end
   local url = _getURL(c8y.resp)
   if not url then
      c8y:send('304,' .. r:value(2) .. ',"Parse URL failed"', 1)
      return
   end
   local name = '"NTC 6200 Device Configuration"'
   local desc = table.concat({'Upload by', rdbGetStr('uboot.sn'), 'at',
                              os.date('%x %X', os.time())}, ' ')
   c8y:send(table.concat({'331', name, desc, url}, ','), 1)
   opid = r:value(2)
end


function downloadConfig(r)
   local id = string.match(r:value(3), '/(%d+)$')
   if not id then
      c8y:send('304,' .. r:value(2) .. ',"URL parse error!"', 1)
      return
   end
   c8y:send('303,' .. r:value(2) .. ',EXECUTING')
   if c8y:getf(id, p) < 0 then
      c8y:send('304,' .. r:value(2) .. ',"Download config failed"', 1)
      return
   end
   _presaveConfig()
   if not os.execute('install_file ' .. p) then
      c8y:send('304,' .. r:value(2) .. ',"Install config failed"', 1)
      return
   end
   c8y:send(table.concat({'332', c8y.ID, r:value(4)}, ','), 1)
   _saveOp(r:value(2))
   rdbSet('service.system.reset', '1')
end


function setSnapshot(r)
   if r:value(3) == 'c8y_ConfigurationDump' then
      c8y:send(table.concat({'332', c8y.ID, r:value(2)}, ','), 1)
      if opid then c8y:send('303,' .. opid .. ',SUCCESSFUL', 1) end
      opid = nil
   end
end


function init()
   c8y:addMsgHandler(805, 'updateConfig')
   c8y:addMsgHandler(841, 'sendConfig')
   c8y:addMsgHandler(842, 'uploadConfig')
   c8y:addMsgHandler(843, 'downloadConfig')
   c8y:addMsgHandler(844, 'setSnapshot')

   c8y:addMsgHandler(854, 'updateConfig')
   c8y:addMsgHandler(871, 'sendConfig')
   c8y:addMsgHandler(872, 'uploadConfig')
   c8y:addMsgHandler(873, 'downloadConfig')
   local id = _loadOp()
   if id then
      local tbl = _getConfig()
      if tbl then
         local value = '"' .. table.concat(tbl, '\\n') .. '"'
         c8y:send(table.concat({'316', c8y.ID, value}, ','))
      end
      c8y:send('303,' .. id .. ',SUCCESSFUL', 1)
   end
   return 0
end
