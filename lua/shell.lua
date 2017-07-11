require('myrdb')
local shpath = '/opt/ntcagent/shell.txt'
local keyServer = 'service.cumulocity.connection.server'
local keyPass = 'service.cumulocity.connection.password'
local keyFactory = 'service.system.factory'
local keyReset = 'service.system.reset'


local function _sleep(sec)
   os.execute('sleep ' .. sec)
end


local function _save(opid, cmdline, start, res)
   local file = io.open(shpath, 'w')
   if not file then return end
   file:write(table.concat({opid, cmdline, start}, '\n'))
   file:write('\n', table.concat(res, '\n'))
   file:close()
end


local function _load()
   local file = io.open(shpath, 'r')
   if not file then return end
   local opid = tonumber(file:read('*l'))
   local cmdline = file:read('*l')
   local start = tonumber(file:read('*l')) or 1
   local res = {}
   for l in file:lines() do res[#res + 1] = l end
   file:close()
   if start > #res + 1 then res[#res + 1] = '' end
   return opid, cmdline, start, res
end


local function shell(cmd, key, value)
   local state, res = true, ''
   if cmd == 'get' then
      res = rdbGetStr(key, '<not found>')
      state = res ~= '<not found>'
   elseif cmd == 'set' then
      rdbSet(key, value)
      rdbSetFlags(key, 'p')
   elseif cmd == 'execute' then
      if key == 'reboot' then
         rdbSet(keyReset, '1')
      elseif key == 'pdpcycle' then
         rdbSet('link.profile.1.enable', '0')
         _sleep(10)
         rdbSet('link.profile.1.enable', '1')
         _sleep(10)
      else
         state, res = false, 'Unsupported execute command'
      end
   else
      state, res = false, 'Invalid command'
   end
   return state, res
end


local function _eval(opid, cmdline, start, res)
   local state, v, i, a = true, '', 1, 0
   for cmd in string.gmatch(cmdline, '([^;]+)') do
      i = i + 1
      if i > start then
         local l, issave, isbreak = {}, false, false
         for j in string.gmatch(cmd, '[^%s=]+') do l[#l + 1] = j end
         if l[1] == 'set' then
            isbreak = l[2] == keyFactory
            issave = l[2] == keyReset
         elseif l[1] == 'execute' then
            issave = l[2] == 'reboot'
         end
         if isbreak then c8y:send('303,' .. opid .. ',SUCCESSFUL', 1)
         elseif issave then
            _save(opid, cmdline, i, res)
            c8y:send('303,' .. opid .. ',EXECUTING')
         end
         state, v = shell(l[1], l[2], l[3])
         res[#res + 1] = string.gsub(v, '"', '""')
         if isbreak or issave then return
         elseif not state then break end
      end
   end
   local s = state and 'SUCCESSFUL' or 'FAILED'
   local s2 = '"' .. table.concat(res, ';') .. '"'
   local cmd = '"' .. string.gsub(cmdline, '"', '""') .. '"'
   c8y:send(table.concat({'310', opid, s, cmd, s2}, ','), 1)
   local file = io.open(shpath, 'w')
   if file then file:close() end
end


function eval(r)
   if r.size < 4 then
      c8y:send('304,' .. r:value(2) .. ',"No command found"', 1)
   else
      _eval(r:value(2), r:value(3), 1, {})
   end
end


function init()
   c8y:addMsgHandler(807, 'eval')
   c8y:addMsgHandler(855, 'eval')
   local opid, cmdline, start, res = _load()
   if opid and cmdline then _eval(opid, cmdline, start, res) end
   return 0
end
