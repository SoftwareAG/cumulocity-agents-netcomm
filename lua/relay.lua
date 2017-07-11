require('myrdb')
local prefix = 'sys.sensors.io.'
local gpios = {'xaux1', 'xaux2', 'xaux3'}


local function reportArray()
   local tbl = {'324', c8y.ID}
   for _, v in ipairs(gpios) do
      local i = rdbGetInt(prefix .. v .. '.d_out')
      tbl[#tbl + 1] = i == 1 and 'OPEN' or 'CLOSED'
   end
   c8y:send(table.concat(tbl, ','))
end


function init()
   reportArray()
   c8y:addMsgHandler(838, 'exec')
   c8y:addMsgHandler(870, 'exec')
   return 0
end


function exec(r)
   if r.size < 6 then return end
   for i = 3, 5 do
      local v = r:value(i) == 'OPEN' and 1 or 0
      rdbSet(prefix .. gpios[i - 2] .. '.d_out', v)
   end
   reportArray()
   c8y:send('303,' .. r:value(2) .. ',SUCCESSFUL', 1)
end
