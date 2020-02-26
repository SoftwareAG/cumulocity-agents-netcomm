require('myrdb')
local sigTimer
local t0 = 0


function init()
   sigTimer = c8y:addTimer(1*1000, 'sendSignal')
   sigTimer:start()
   return 0
end


local function _sendSignal()
   local type = rdbGetStr('wwan.0.system_network_status.system_mode')
   local signal = rdbGetInt('wwan.0.radio.information.signal_strength')
   if type == 'LTE' then
      local rsrq = rdbGetInt('wwan.0.signal.rsrq')
      c8y:send(string.format("307,%s,%s,%s,%s,%s,%s,%s,%s", utcTime(), c8y.ID, 'RSRP', signal, 'dBm', 'RSRQ', rsrq, 'dB'))
   elseif type == 'UMTS' then
      c8y:send(string.format("308,%s,%s,%s,%s,%s", utcTime(), c8y.ID, 'RSCP', signal, 'dBm'))
   elseif type == 'GSM' then
      c8y:send(string.format("308,%s,%s,%s,%s,%s", utcTime(), c8y.ID, 'RSSI', signal, 'dBm'))
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
