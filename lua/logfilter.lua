local months = {Jan = 1, Feb = 2, Mar = 3, Apr = 4, May = 5, Jun = 6,
                Jul = 7, Aug = 8, Sep = 9, Oct = 10, Nov = 11, Dec = 12}


function get_boottime()
   local file = io.open('/proc/uptime')
   local uptime = file:read('*n')
   file:close()
   return os.time() - uptime
end

local boottime = get_boottime()


function syslog_b_filter(line, start)
   local t = {string.match(line, '(%w+)%s+(%d+)%s+(%d+):(%d+):(%d+)')}
   local b = false
   if #t == 5 then
      local lt = os.time{year=os.date('%Y'), month=months[t[1]],
                         day=t[2], hour=t[3], min=t[4], sec=t[5]}
      b = lt >= start
   end
   return b
end


function syslog_e_filter(line, stop)
   local t = {string.match(line, '(%w+)%s+(%d+)%s+(%d+):(%d+):(%d+)')}
   local b = true
   if #t == 5 then
      local lt = os.time{year=os.date('%Y'), month=months[t[1]],
                         day=t[2], hour=t[3], min=t[4], sec=t[5]}
      b = lt <= stop
   end
   return b
end


function dmesg_b_filter(line, start)
   local t = string.match(line, '%[%s*([%d%.]+)') or 0
   return (t + boottime) >= start
end


function dmesg_e_filter(line, stop)
   local t = string.match(line, '%[%s*([%d%.]+)') or 0
   return (t + boottime) <= stop
end


function true_filter(line, pos)
   return true
end
