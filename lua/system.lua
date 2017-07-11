require('myrdb')
local key = 'service.cumulocity.system_resources.interval'
local path = '/sys/class/net/br0/statistics/'
local timer
local interval
local t, beg = 0
local rx, tx


local function getMemUsage()
   local memTotal, memUse
   local file = io.popen('free')
   if file then
      file:read('*l')
      local value = file:read('*l')
      file:close()
      memTotal, memUse = string.match(value, "%S+%s+(%d+)%s+(%d+)")
   end
   return memTotal, memUse
end


local function getSystemLoad()
   local file = io.popen('cat /proc/loadavg')
   local value = file:read('*n')
   file:close()
   return value or 0
end


local function getNetStat()
   local file = io.open(path .. 'rx_bytes')
   local _rx, _tx
   if file then
      _rx = file:read('*n')
      file:close()
   end
   file = io.open(path .. 'tx_bytes')
   if file then
      _tx = file:read('*n')
      file:close()
   end
   return _rx, _tx
end


function report()
   interval = rdbGetInt(key)
   local t1 = os.time()
   if interval == 0 or t + interval > t1 then return end

   t = t1
   local total, use = getMemUsage()
   if total and use then
      total, use = math.floor(total / 1024), math.floor(use / 1024)
      c8y:send(table.concat({'325', utcTime(), c8y.ID, use, total}, ','), 0)
   end

   local v = getSystemLoad()
   if v then
      c8y:send(table.concat({'326', utcTime(), c8y.ID, v * 50}, ','), 0)
   end

   local _rx, _tx = getNetStat()
   if _rx and _tx then
      local now = os.time()
      local _val = now - beg
      beg = now
      local v1, v2 = _rx - rx, _tx - tx
      rx, tx = _rx, _tx
      _val = _val >= 0 and (_val + 1) * 1024 or (-_val + 1) * 1024
      v1 = v1 >= 0 and v1 / _val or -v1 / _val
      v2 = v2 >= 0 and v2 / _val or -v2 / _val
      v1, v2 = string.format('%.3f', v1), string.format('%.3f', v2)
      c8y:send(table.concat({'330', utcTime(), c8y.ID, v1, v2}, ','), 0)
   end
end


function init()
   beg = os.time()
   rx, tx = getNetStat()
   rx, tx = rx or 0, tx or 0
   timer = c8y:addTimer(1000, 'report')
   timer:start()
   return 0
end
