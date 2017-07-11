require('luardb')
local pattern = '^%s*([+-]?%d+%.?%d*)'

function rdbGetInt(key, default)
   default = default or 0
   local value = tonumber(string.match(luardb.get(key) or '', pattern))
   return value or default
end


function rdbGetStr(key, default)
   default = default or ''
   return luardb.get(key) or default
end


function rdbSet(key, value)
   luardb.set(key, value or '')
end


function rdbSetFlags(key, flags)
   luardb.setFlags(key, flags or '')
end


function utcTime()
   local s = os.date('!*t')
   return string.format('%04d-%02d-%02dT%02d:%02d:%02d+0000',
                        s.year, s.month, s.day, s.hour, s.min, s.sec)
end
