require('myrdb')
local sigTimer
local t0 = 0


function init()
   sigTimer = c8y:addTimer(1*1000, 'sendSignal')
   sigTimer:start()
   return 0
end


local function _sendSignal()
   local rssi = rdbGetInt('wwan.0.radio.information.signal_strength')
   local rscp = rdbGetInt('wwan.0.system_network_status.RSCPs0', -1)
   local rsrp = rdbGetInt('wwan.0.signal.0.rsrp')
   local a = rscp == -1 and 'RSRP' or 'RSCP'
   local b = rscp == -1 and rsrp or rscp
   local valid = rdbGetInt('wwan.0.system_network_status.ECN0_valid')
   if valid == 1 then
      local ecn0 = rdbGetInt('wwan.0.system_network_status.ECN0s0')
      c8y:send(table.concat({'307', utcTime(), c8y.ID, rssi, a, b, ecn0}, ','), 1)
   else
      c8y:send(table.concat({'308', utcTime(), c8y.ID, rssi, a, b}, ','), 1)
   end
end


function sendSignal()
   local val = rdbGetInt('service.cumulocity.signal.interval')
   local t1 = os.time()
   if val > 0 and os.difftime(t1, t0) > val then
      _sendSignal()
      t0 = t1
   end
end
