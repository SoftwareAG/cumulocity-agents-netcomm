require('myrdb')

local keyVal = 'service.cumulocity.gps.interval'
local keyUpVal = 'service.cumulocity.gps.update_interval'
local keyLat = 'sensors.gps.0.standalone.latitude'
local keyLon = 'sensors.gps.0.standalone.longitude'
local keyAlt = 'sensors.gps.0.standalone.altitude'
local keyVel = 'sensors.gps.0.standalone.ground_speed_kph'
local keyDate = 'sensors.gps.0.standalone.date'
local keyTime = 'sensors.gps.0.standalone.time'

local timer
local puTimer
local counter = 0
local t0, t1 = 0, 0
local val, upval


local function _parse(value, direction)
   local D, M = string.match(value, '(%d+)(%d%d%.%d+)')
   if D and M then
      local v = D + M / 60
      return (direction == 'S' or direction == 'W') and -v or v
   end
end


local function getPos()
   local v, dir = rdbGetStr(keyLat), rdbGetStr(keyLat .. '_direction')
   local _lat = _parse(v, dir)
   v, dir = rdbGetStr(keyLon), rdbGetStr(keyLon .. '_direction')
   local _lon = _parse(v, dir)
   local _alt = rdbGetInt(keyAlt)
   return _lat, _lon, _alt
end


local function updateEvent(alt, lat, lon)
   local vel = rdbGetInt(keyVel)
   local t = rdbGetStr(keyDate) .. ' ' .. rdbGetStr(keyTime)
   if #t > 1 then
      c8y:send(table.concat({'329',utcTime(),c8y.ID,alt,lat,lon,vel,t}, ','), 1)
   end
end


function update()
   if rdbGetInt('sensors.gps.0.enable') ~= 1 then return end
   local lat, lon, alt = getPos()
   if not (lat and lon and alt) then return end

   local t = os.time()
   val, upval = rdbGetInt(keyVal), rdbGetInt(keyUpVal)
   if val > 0 and val + t0 <= t then
      t0 = t
      updateEvent(alt, lat, lon)
   end
   if upval > 0 and upval + t1 <= t then
      t1 = t
      c8y:send(table.concat({'328', c8y.ID, alt, lat, lon}, ','))
   end
end


function reportPos()
   local lat, lon, alt = getPos()
   if lat and lon and alt then
      counter = 10
      c8y:send(table.concat({'328', c8y.ID, alt, lat, lon}, ','))
   else
      counter = counter + 1
   end
   if counter >= 5 then
      puTimer:stop()
   end
end


function init()
   timer = c8y:addTimer(1 * 1000, 'update')
   timer:start()
   puTimer = c8y:addTimer(180 * 1000, 'reportPos')
   puTimer:start()
   return 0
end
