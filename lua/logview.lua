require('logfilter')
local fpath = '/opt/ntcagent/tmplog.log'

function init()
   c8y:addMsgHandler(813, 'logview')
   c8y:addMsgHandler(858, 'logview')
   local v = table.concat({'""ntcagent""', '""dmesg""', '""logread""',
                           '""ipsec""'}, ',')
   c8y:send('317,' .. c8y.ID .. ',"' .. v .. '"')
   return 0
end


-- Convert ISO time (2011-05-12T13:12:32+0100) to utc seconds since epoch
function utc_time(time)
   local tfmt = '(%d+)-(%d+)-(%d+)T(%d+):(%d+):(%d+)[.%d]*'
   local tbl = {string.match(time, tfmt)}
   if #tbl < 6 then return end
   local st = os.time{year=tbl[1], month=tbl[2], day=tbl[3],
                      hour=tbl[4], min=tbl[5], sec=tbl[6]}
   local tz = string.match(time, '[+-]%d+:?%d+$')
   local num = tz and tonumber(string.sub(tz, 1, 3)) or 0
   return st + num * 3600
end


-- UTC + tzsec() = LOCAL
local function tzsec()
   local now = os.time()
   local utc, loc = os.date('!*t', now), os.date('*t', now)

   return (loc.hour - utc.hour) * 3600
end


local function ntcagent_iter(start, stop, match, limit)
   return io.open('/opt/ntcagent/ntcagent.log'), syslog_b_filter, syslog_e_filter
end


local function dmesg_iter(start, stop, match, limit)
   return io.popen('dmesg'), dmesg_b_filter, dmesg_e_filter
end


local function logread_iter(start, stop, match, limit)
   return io.popen('logread'), syslog_b_filter, syslog_e_filter
end


local function ipsec_iter(start, stop, match, limit)
   return io.open('/tmp/ipseclog'), true_filter, true_filter
end


local function _log(logtype, start, stop, match, limit)
   local file, bf, ef

   if logtype == 'ntcagent' then
      file, bf, ef = ntcagent_iter(start, stop, match, limit)
   elseif logtype == 'logread' then
      file, bf, ef = logread_iter(start, stop, match, limit)
   elseif logtype == 'dmesg' then
      file, bf, ef = dmesg_iter(start, stop, match, limit)
   elseif logtype == 'ipsec' then
      file, bf, ef = ipsec_iter(start, stop, match, limit)
   end

   if not file then return nil end
   local tbl, index = {}, 1
   for line in file:lines() do
      if bf(line, start) then
         if ef(line, stop) and string.match(line, match) then
            tbl[index] = line
            index = 2
         end
         break
      end
   end
   for line in file:lines() do
      if not ef(line, stop) then break end
      if string.match(line, match) then
         tbl[index] = line
         index = index % limit + 1
      end
   end

   file:close()
   local file2 = io.open(fpath, 'w')
   if not file2 then return end
   for i = index, #tbl do file2:write(tbl[i], '\n') end
   for i = 1, index - 1 do file2:write(tbl[i], '\n') end
   file2:close()

   return true
end


local function getFileUrl(json)
   local urlmatch = '"self":"([^ {},?]+/inventory/)%w+/(%d+)"'
   local prefix, id = string.match(json, urlmatch)

   if prefix and id then
      return prefix .. 'binaries/' .. id
   end
end


function logview(r)
   local start = utc_time(r:value(4))
   local stop = utc_time(r:value(5))
   local text

   if not start then
      text = ',"Unparse-able time: ' .. r:value(4) .. '"'
   end
   if not stop then
      text = ',"Unparse-able time: ' .. r:value(5) .. '"'
   end

   if text then
      c8y:send('304,' .. r:value(2) .. text)
      return
   end

   c8y:send('303,' .. r:value(2) .. ',EXECUTING')

   start, stop = start + tzsec(), stop + tzsec()
   if not _log(r:value(3), start, stop, r:value(7), tonumber(r:value(6))) then
      c8y:send('304,' .. r:value(2) .. ',"read/write log failed"', 1)
      return
   end

   if c8y:postf(r:value(3) .. '.log', "text/plain", fpath) < 0 then
      c8y:send('304,' .. r:value(2) .. ',"upload log failed"', 1)
      return
   end

   local u = getFileUrl(c8y.resp)
   if not u then
      c8y:send('304,' .. r:value(2) .. ',"Parse URL failed"', 1)
      return
   end

   c8y:send(table.concat({'318', r:value(2), r:value(3), r:value(4), r:value(5), r:value(6), r:value(7), u}, ','), 1)

   -- remove tmp file --
   os.remove(fpath);

end
