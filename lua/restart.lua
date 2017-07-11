local fpath = '/opt/ntcagent/restart.txt'

function restart(r)
   if r:value(0) == '853' then
      c8y:send('303,' .. r:value(2) .. ',SUCCESSFUL', 1)
      return
   end
   c8y:send('303,' .. r:value(2) .. ',EXECUTING')
   local file = io.open(fpath, 'w')
   if not file then
      c8y:send('304,' .. r:value(2) .. ',"failed to store op ID"', 1)
      return
   end
   file:write(r:value(2))
   file:close()
   local ret = os.execute('reboot')
   if ret ~= 0 then
      os.remove(fpath)
      c8y:send('304,' .. r:value(2) .. ',"error code: ' .. ret .. '"', 1)
   end
end


function init()
   c8y:addMsgHandler(804, 'restart')
   c8y:addMsgHandler(853, 'restart')
   local file = io.open(fpath, 'r')
   local opid
   if file then
      opid = file:read('*n')
      file:close()
      os.remove(fpath)
   end
   if opid then c8y:send('303,' .. opid .. ',SUCCESSFUL', 1) end
   return 0
end
