require('myrdb')
local cmd_list = 'ipkg-cl list '
local cmd_install = 'ipkg-cl install -force-downgrade '
local cmd_remove = 'ipkg-cl remove '
local receives = {}
local pkg_fmt = '{""name"":""%s"",""version"":""%s"",""url"":"" ""}'
local pkg_path = '/opt/cdcs/upload/'
local fpath = '/opt/ntcagent/software.txt'
local errmsgs = {[-1] = '"Unknown reason"',
   [-2] = '"Download failed"',
   [-3] = '"Install/update failed"',
   [4] = '"Invalid package"',
   [129] = '"Uninstall agent not permitted"',
   [256] = '"Package not exist"'
}


local function getFirmware()
   return rdbGetStr('system.product.model'), rdbGetStr('sw.version')
end


local function strerr(errno)
   return errmsgs[errno] or ('errno:' .. errno)
end


local function pack(tbl)
   local t = {}
   for name, version in pairs(tbl) do
      table.insert(t, string.format(pkg_fmt, name, version))
   end
   return '"' .. table.concat(t, ',') .. '"'
end


local function pkg_list()
   local tbl = {}
   local file = io.popen(cmd_list)
   for line in file:lines() do
      local name, version = string.match(line, '([%w-]+)%s+-%s+([%d%.]+)')
      if name and version then tbl[name] = version end
   end
   file:close()
   return tbl
end


local function pkg_perform(cmd, pkgs)
   local param = cmd .. pkgs
   srInfo('software: ' .. param)
   return os.execute(param) or -3
end


local function pkg_batch(tbl, cmd)
   if #tbl > 0 then
      local param = table.concat(tbl, ' ')
      return pkg_perform(cmd, param)
   else
      return 0
   end
end


local function _save(path, data)
   local file = io.open(path, 'w')
   if file then
      file:write(data)
      file:close()
   end
end


local function _load(path)
   local file = io.open(path)
   local data
   if file then
      data = file:read('*a')
      file:close()
   end
   return data
end


function clear(r)
   receives = {}
end


function aggregate(r)
   receives[r:value(2)] = {r:value(3), r:value(4)}
end


function perform(r)
   c8y:send('303,' .. r:value(2) .. ',EXECUTING')
   local locallist = pkg_list()
   local installs = {}
   for k, v in pairs(receives) do
      local id = string.match(v[2], '/(%w+)$')
      if v[1] ~= locallist[k] then installs[k] = {v[1], id} end
      locallist[k] = nil
   end
   receives = {}

   local c, tbl = 0, {}

   for name, _ in pairs(locallist) do
      tbl[#tbl + 1] = name
      if name == 'smartrest-agent' then c = 129 end
   end
   if c~= 0 then
      c8y:send('319,' .. c8y.ID .. ',' .. pack(pkg_list()))
      c8y:send('304,' .. r:value(2) .. ',' .. strerr(c), 1)
      return
   end
   c = pkg_batch(tbl, cmd_remove)
   if c ~= 0 then
      c8y:send('319,' .. c8y.ID .. ',' .. pack(pkg_list()))
      c8y:send('304,' .. r:value(2) .. ',' .. strerr(c), 1)
      return
   end

   tbl = {}

   for name, v in pairs(installs) do
      local filename = pkg_path .. name .. '_arm.ipk'
      if c8y:getf(v[2], filename) > 0 then
         tbl[#tbl + 1] = filename
      else
         c = -2
         break
      end
   end
   if c ~= 0 then
      c8y:send('319,' .. c8y.ID .. ',' .. pack(pkg_list()))
      c8y:send('304,' .. r:value(2) .. ',' .. strerr(c), 1)
      return
   end

   c = pkg_batch(tbl, cmd_install)
   if c ~= 0 then
      c8y:send('319,' .. c8y.ID .. ',' .. pack(pkg_list()))
      c8y:send('304,' .. r:value(2) .. ',' .. strerr(c), 1)
      return
   end

   _save(fpath, r:value(2))
   rdbSet('service.system.reset', '1')
end


function update_firmware(r)
   if r:value(3) == rdbGetStr('sw.version') then
      c8y:send('303,' .. r:value(2) .. ',SUCCESSFUL', 1)
      return
   end
   local id = string.match(r:value(4), '/(%w+)$')
   if not id then
      c8y:send('304,' .. r:value(2) .. ',"Wrong URL:' .. r:value(4) .. '"', 1)
      return
   end
   c8y:send('303,' .. r:value(2) .. ',EXECUTING')
   local filename = pkg_path .. 'firmware.cdi'
   if c8y:getf(id, filename) <= 0 then
      c8y:send(table.concat({'304', r:value(2), strerr(-2)}, ','), 1)
      return
   end
   local c = os.execute('install_file ' .. filename) or -3
   if c ~= 0 then
      c8y:send(table.concat({'304', r:value(2), strerr(c)}, ','), 1)
   else
      _save(fpath, r:value(2))
   end
end


function query(r)
   c8y:send('315,' .. r:value(2))
end


function init()
   c8y:addMsgHandler(837, 'clear')
   c8y:addMsgHandler(814, 'aggregate')
   c8y:addMsgHandler(815, 'perform')
   c8y:addMsgHandler(845, 'update_firmware')

   c8y:addMsgHandler(859, 'query')
   c8y:addMsgHandler(874, 'update_firmware')
   local name, version = getFirmware()
   local opid = tonumber(_load(fpath))
   if opid then
      _save(fpath, '')
      c8y:send('303,' .. opid .. ',SUCCESSFUL', 1)
   end
   c8y:send(table.concat({'333', c8y.ID, name, version, '" "'}, ','))
   c8y:send('319,' .. c8y.ID .. ',' .. pack(pkg_list()))
   return 0
end
