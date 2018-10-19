require('myrdb')

-- coil, discrete input, holding register, input register
local CO, DI, HR, IR = {}, {}, {}, {}

local MBDEVICES, MBTYPES = {}, {}
local DTYPE = nil

-- MBDEVICES index
-- coil, discrete input, holding register, input register
local dcono, ddino, dhrno, dirno = 1, 2, 3, 4
-- address, slave, modbus type, modbus object
local daddrno, dslaveno, dtypeno, dobjno, dunvno = 5, 6, 7, 8, 9

-- number, alarm, measurement, event, status (index for CO, DI, HR and IR)
local no, alno, meno, evno, stno = 1, 2, 3, 4, 5

-- startBits, noBits, factor, sign (index for HR and IR)
local rsbno, rnbno, rftno, rsino = 6, 7, 8, 9
local rleno = 10
-- MBTYPES index
local tstno = 1                 -- server time
local tmdno = 2                 -- modbus data model

local pollingRate, transmitRate, port
local serPort, serBaud, serPar, serData, serStop
local timer0, timer1
local keyPort = 'service.cumulocity.modbus.port'
local keyPollingRate = 'service.cumulocity.modbus.pollingrate'
local keyTransmitRate = 'service.cumulocity.modbus.transmitrate'
local keyReadonly = 'service.cumulocity.modbus.readonly'
local keySerPort = 'service.cumulocity.modbus.serial.port'
local keySerBaud = 'service.cumulocity.modbus.serial.baud'
local keySerData = 'service.cumulocity.modbus.serial.databits'
local keySerPar = 'service.cumulocity.modbus.serial.parity'
local keySerStop = 'service.cumulocity.modbus.serial.stopbits'
local t0, t1


function addDevice(r)
   local slave, device = tonumber(r:value(3)), tonumber(r:value(4))
   if MBDEVICES[device] then
      if r.size >= 7 then c8y:send('303,' .. r:value(6) .. ',SUCCESSFUL', 1) end
      return
   elseif r:value(2) == 'TCP' then
      return
   elseif r:value(2) == 'RTU' and serPort == '' then
      if r.size >= 7 then
         c8y:send('304,' .. r:value(6) .. ',"serial port unspecified"', 1)
      end
      return
   end

   local addr = r:value(2) == 'RTU' and serPort or r:value(2)
   local obj = r:value(2) ~= 'RTU' and MB:newTCP(addr, port) or
      MB:newRTU(addr, serBaud, serPar, serData, serStop)
   DTYPE = tonumber(string.match(r:value(5), '/(%d+)$'))
   MBDEVICES[device] = {{}, {}, {}, {}, addr, slave, DTYPE, obj}

   if not MBTYPES[DTYPE] then        -- new unknow modbus type
      local model = MB:newModel()
      MBTYPES[DTYPE] = {false, model}
      CO[DTYPE], DI[DTYPE], HR[DTYPE], IR[DTYPE] = {}, {}, {}, {}
      c8y:send('309,' .. DTYPE)
   end
   if r.size >= 7 then
      c8y:send('303,' .. r:value(6) .. ',SUCCESSFUL', 1)
   else
      c8y:send('314,' .. device .. ',PENDING\n311,' ..device ..
                  ',ACTIVE\n311,' .. device .. ',ACKNOWLEDGED')
   end
end


function saveConfigure(r)
   local a, b = tonumber(r:value(3)), tonumber(r:value(4))
   if a and b then
      pollingRate, transmitRate = a, b
      rdbSet(keyPollingRate, pollingRate)
      rdbSet(keyTransmitRate, transmitRate)
      c8y:send(table.concat({'321', c8y.ID, r:value(3), r:value(4), 5}, ','))
      c8y:send('303,' .. r:value(2) .. ',SUCCESSFUL', 1)
   else
      c8y:send('304,' .. r:value(2) .. ',Invalid_Number', 1)
   end
end


function saveSerialConfiguration(r)
   local baud, data = tonumber(r:value(3)), tonumber(r:value(4))
   local par, stop = r:value(5), tonumber(r:value(6))
   if  baud ~= serBaud or  data ~= serData or par ~= serPar or
   stop ~= serStop then
      rdbSet(keySerBaud, baud)
      rdbSet(keySerData, data)
      rdbSet(keySerPar, par)
      rdbSet(keySerStop, stop)
      serBaud, serData, serPar, serStop = baud, data, par, stop
      local obj = MB:newRTU(serPort, baud, par, data, stop)
      obj:setConf(serPort, baud, par, data, stop)
      c8y:send(table.concat({'335', c8y.ID, baud, data, par, stop}, ','))
   end
   c8y:send('303,' .. r:value(2) .. ',SUCCESSFUL', 1)
end


local function cmp1(lhs, rhs) return lhs[no] - rhs[no] end

local function cmp2(lhs, rhs)
   return (lhs[no]~=rhs[no]) and lhs[no]-rhs[no] or lhs[rsbno]-rhs[rsbno]
end

local function cmp3(lhs, rhs) return lhs - rhs end


local function bsearch(tbl, hint, cmp)
   local low, mid, high = 1, 0, #tbl
   while low <= high do
      mid = math.floor((low + high) / 2)
      local ret = cmp(tbl[mid], hint)
      if ret < 0 then low = mid + 1
      elseif ret > 0 then high = mid - 1
      else return mid
      end
   end
end


local function rinsert(tbl, item, cmp)
   local i = #tbl
   while i > 0 and cmp(tbl[i], item) > 0 do i = i - 1 end
   i = i + 1
   table.insert(tbl, i, item)
end


local function update(tbl, hint, key, value, cmp)
   local i = bsearch(tbl, hint, cmp)
   if i then tbl[i][key] = value end
end


function addCoil(r)
   local mytbl = r:value(3) == 'false' and CO or DI
   local num = tonumber(r:value(2))
   rinsert(mytbl[DTYPE], {num}, cmp1)
   local addrtype = r:value(3) == 'false' and 0 or 1
   MBTYPES[DTYPE][tmdno]:addAddress(addrtype, num - 1)
end


function addCoilAlarm(r)
   local mytbl = r:value(4) == 'false' and CO or DI
   update(mytbl[DTYPE], {tonumber(r:value(2))}, alno, r:value(3), cmp1)
end


function addCoilMeasurement(r)
   local mytbl = r:value(4) == 'false' and CO or DI
   update(mytbl[DTYPE], {tonumber(r:value(2))}, meno, r:value(3), cmp1)
end


function addCoilEvent(r)
   local mytbl = r:value(4) == 'false' and CO or DI
   update(mytbl[DTYPE], {tonumber(r:value(2))}, evno, r:value(3), cmp1)
end


function addCoilStatus(r)
   local mytbl = r:value(4) == 'false' and CO or DI
   update(mytbl[DTYPE], {tonumber(r:value(2))}, stno, '100', cmp1)
end


function addRegister(r)
   local a = tonumber(r:value(2))
   local sb, nb = tonumber(r:value(3)), tonumber(r:value(4))
   local sign = r:value(9) == 'true'
   local mytbl = r:value(8) == 'false' and HR or IR
   local factor = r:value(5) * (10 ^ -r:value(7)) / r:value(6)
   local tbl = {[no] = a, [rsbno] = sb, [rnbno] = nb,
      [rftno] = factor, [rsino] = sign, [rleno] = 0}
   rinsert(mytbl[DTYPE], tbl, cmp2)
   local addrtype = r:value(8) == 'false' and 2 or 3
   local size = math.floor((sb + nb - 1) / 16) + 1
   for i = 0, size - 1 do
      MBTYPES[DTYPE][tmdno]:addAddress(addrtype, a + i - 1)
   end
end


function addRegisterAlarm(r)
   local mytbl = r:value(5) == 'false' and HR or IR
   local hint = {[no] = tonumber(r:value(2)), [rsbno] = tonumber(r:value(3))}
   update(mytbl[DTYPE], hint, alno, r:value(4), cmp2)
end


function addRegisterMeasurement(r)
   local mytbl = r:value(5) == 'false' and HR or IR
   local hint = {[no] = tonumber(r:value(2)), [rsbno] = tonumber(r:value(3))}
   update(mytbl[DTYPE], hint, meno, r:value(4), cmp2)
end


function addRegisterEvent(r)
   local mytbl = r:value(5) == 'false' and HR or IR
   local hint = {[no] = tonumber(r:value(2)), [rsbno] = tonumber(r:value(3))}
   update(mytbl[DTYPE], hint, evno, r:value(4), cmp2)
end


function addRegisterStatus(r)
   local mytbl = r:value(5) == 'false' and HR or IR
   local hint = {[no] = tonumber(r:value(2)), [rsbno] = tonumber(r:value(3))}
   update(mytbl[DTYPE], hint, stno, '101', cmp2)
end


function setServerTime(r)
   MBTYPES[DTYPE][tstno] = r:value(2) == 'true'
end


function setmbtype(r)
   DTYPE = tonumber(r:value(2))
end


local function complement(x, n)
   return x < 0 and 2 ^ n + x or x
end


local function pack(lhs, isServerTime, rhs)
   if not isServerTime then
      local x = os.date('!*t')
      lhs[#lhs + 1] = string.format('%d-%d-%dT%d:%d:%d+00:00', x.year,
                                    x.month, x.day, x.hour, x.min, x.sec)
   end
   if rhs and #rhs >= 1 then
      return table.concat(lhs, ',') .. ',' .. table.concat(rhs, ',')
   else
      return table.concat(lhs, ',')
   end
end


local function pollData(device, num, msgtbl, flags)
   local obj = MBDEVICES[device][dobjno]
   if obj:size(num - 1) <= 0 then return end

   local datatbl, dtype = {CO, DI, HR, IR}, MBDEVICES[device][dtypeno]
   local old, new = MBDEVICES[device][num], {}
   for k, v in pairs(datatbl[num][dtype]) do
      local addr = v[no] - 1
      if num < 3 then
         new[k] = obj:getCoilValue(num - 1, addr)
      else
         local sb, nb = v[rsbno], v[rnbno]
         local signed = v[rsino] and 1 or 0
         local littleEndian = v[rleno] or 0
         new[k] = obj:getRegValue(num - 3, addr, sb, nb, signed, littleEndian)
         new[k] = tonumber(new[k]) * v[rftno]
         local _, rem = math.modf(new[k])
         local fmt = rem == 0 and '%d' or '%f'
         new[k] = string.format(fmt, new[k])
      end

      for _, myno in pairs({alno, meno, evno, stno}) do
         local msgid = v[myno]
         if msgid then
            flags[msgid] = flags[msgid] or (old[k] ~= new[k])
            if not msgtbl[msgid] then msgtbl[msgid] = {} end
            local tbl = msgtbl[msgid]
            tbl[#tbl + 1] = new[k]
         end
      end
      old[k] = new[k]
   end
   return 0
end


local function pollDevice(device)
   local alarms, msgtbl, flags, dtype = {}, {}, {}, MBDEVICES[device][dtypeno]
   if not MBTYPES[dtype] then return -1 end
   local addr, slave = MBDEVICES[device][daddrno], MBDEVICES[device][dslaveno]
   srDebug('Modbus: poll ' .. addr .. '@' .. slave)
   local obj = MBDEVICES[device][dobjno]
   local unavail = obj:poll(slave, MBTYPES[dtype][tmdno]) == -1
   for i = 1, 4 do pollData(device, i, msgtbl, flags) end
   if unavail and not MBDEVICES[device][dunvno] then
         local text = string.format('"%s@%s: %s"', addr, slave, obj:errMsg())
         c8y:send('312,'..device..',c8y_ModbusAvailabilityAlarm,MAJOR,'..text)
   end
   local clear = (not unavail) and MBDEVICES[device][dunvno]
   MBDEVICES[device][dunvno] = unavail

   for _, data in pairs({CO, DI, HR, IR}) do
      for _, v in pairs(data[dtype]) do
         if v[alno] then rinsert(alarms, v[alno], cmp3) end
      end
   end
   local serverTime, msgs = MBTYPES[dtype][tstno], {}
   for msgid, values in pairs(msgtbl) do
      if flags[msgid] then
         local st = (msgid == '100' or msgid == '101') and true or serverTime
         if bsearch(alarms, msgid, cmp3) then
            if values[1] == 0 then clear = true
            else msgs[#msgs + 1] = pack({msgid, device}, st)
            end
         else
            msgs[#msgs + 1] = pack({msgid, device}, st, values)
         end
      end
   end
   if #msgs > 0 then
      msgs[1] = dtype .. ',' .. msgs[1]
      c8y:send(table.concat(msgs, '\n'), serverTime and 2 or 3)
   end
   if clear then
      c8y:send('311,'..device..',ACTIVE\n311,'..device..',ACKNOWLEDGED')
   end
end


function poll()
   local t = os.time()
   pollingRate = rdbGetInt(keyPollingRate, pollingRate)
   if t0 + pollingRate > t then return end

   t0 = t
   for device, _ in pairs(MBDEVICES) do pollDevice(device) end
end


local function transmitData(device, isHolding, res)
   local dtype, mbdevice = MBDEVICES[device][dtypeno], MBDEVICES[device]
   local values = isHolding and mbdevice[dhrno] or mbdevice[dirno]
   local data = isHolding and HR or IR
   for k, v in pairs(data[dtype]) do
      local msgid = v[meno]
      if msgid and values[k] then
         if not res[msgid] then res[msgid] = {} end
         local tbl = res[msgid]
         tbl[#tbl + 1] = values[k]
      end
   end
end


function transmit()
   local t = os.time()
   transmitRate = rdbGetInt(keyTransmitRate, transmitRate)
   if t1 + transmitRate > t then return end
   t1 = t
   for device, _ in pairs(MBDEVICES) do
      local msgtbl, dtype = {}, MBDEVICES[device][dtypeno]
      transmitData(device, true, msgtbl)
      transmitData(device, false, msgtbl)

      local msgs, serverTime = {}, MBTYPES[dtype][tstno]
      for msgid, values in pairs(msgtbl) do
         msgs[#msgs + 1] = pack({msgid, device}, serverTime, values)
      end
      if #msgs > 0 then
         msgs[1] = dtype .. ',' .. msgs[1]
         c8y:send(table.concat(msgs, '\n'), serverTime and 2 or 3)
      end
   end
end


function setCoil(r)
   if rdbGetInt(keyReadonly) == 1 then
      c8y:send('304,' .. r:value(2) .. ',Permission_Denied', 1)
      return
   end
   local device = tonumber(r:value(3))
   local mbd = MBDEVICES[device]
   if not mbd then
      c8y:send('304,' .. r:value(2) .. ',Unknown_Modbus_Device', 1)
      return
   end

   local obj, coil = mbd[dobjno], tonumber(r:value(4)) - 1
   if obj:updateCO(mbd[dslaveno], coil, tonumber(r:value(5))) == -1 then
      c8y:send('304,' .. r:value(2) .. ',"' .. obj:errMsg() .. '"', 1)
   else
      pollDevice(device)
      c8y:send('303,' .. r:value(2) .. ',SUCCESSFUL', 1)
   end
end


function setRegister(r)
   if rdbGetInt(keyReadonly) == 1 then
      c8y:send('304,' .. r:value(2) .. ',Permission_Denied', 1)
      return
   end
   local device, reg = tonumber(r:value(3)), tonumber(r:value(4))
   local mbd = MBDEVICES[device]
   if not mbd then
      c8y:send('304,' .. r:value(2) .. ',Unknown_Modbus_Device', 1)
      return
   end
   local dtype = mbd[dtypeno]
   if not HR[dtype] then
      c8y:send('304,' .. r:value(2) .. ',Unknown_Modbus_Type', 1)
      return
   end
   local sb, nb = tonumber(r:value(5)), tonumber(r:value(6))
   local index = bsearch(HR[dtype], {[no] = reg, [rsbno] = sb}, cmp2)
   if not index then
      c8y:send('304,' .. r:value(2) .. ',Register_Not_Found', 1)
      return
   end
   local regtbl = HR[dtype][index]
   local value = math.floor(r:value(7) / regtbl[rftno] + 0.5)
   local isoutrange = false
   if regtbl[rsino] then
      isoutrange = value < -2 ^ (nb - 1) or value >= 2 ^ (nb - 1)
   else
      isoutrange = value < 0 or value >= 2 ^ nb
   end
   if isoutrange then
      c8y:send('304,' .. r:value(2) .. ',Value_Range_Error', 1)
      return
   end
   value = regtbl[rsino] and complement(value, nb) or value

   local obj = mbd[dobjno]
   local littleEndian = regtbl[rleno] or 0
   local rc = obj:updateHRBits(mbd[dslaveno], reg - 1, value, sb, nb, littleEndian)
   if rc == -1 then
      c8y:send('304,' .. r:value(2) .. ',"' .. obj:errMsg() .. '"', 1)
   else
      pollDevice(device)
      c8y:send('303,' .. r:value(2) .. ',SUCCESSFUL', 1)
   end
end


function clearCoilAlarm(r)
   local mbd = MBDEVICES[tonumber(r:value(3))]
   if not mbd then return end
   local dtype = mbd[dtypeno]
   if not dtype then return end
   local tbl = r:value(5) == 'false' and CO[dtype] or DI[dtype]
   local obl = r:value(5) == 'false' and mbd[dcono] or mbd[ddino]
   local index = bsearch(tbl, {tonumber(r:value(4))}, cmp1)
   if index and obl[index] == 0 then c8y:send('313,' .. r:value(2)) end
end


function clearRegisterAlarm(r)
   local device, number = tonumber(r:value(3)), tonumber(r:value(4))
   local mbd = MBDEVICES[device]
   if not mbd then return end
   local dtype = mbd[dtypeno]
   if not dtype then return end
   local tbl = r:value(7) == 'false' and HR[dtype] or IR[dtype]
   local obl = r:value(7) == 'false' and mbd[dhrno] or mbd[dirno]
   local hint = {[no] = number, [rsbno] = tonumber(r:value(5))}
   local index = bsearch(tbl, hint, cmp2)
   if index and obl[index] and math.abs(obl[index]) < 0.000001 then
         c8y:send('313,' .. r:value(2))
   end
end


function clearAvailabilityAlarm(r)
   if r:value(3) == 'c8y_ModbusAvailabilityAlarm' then
      local mbd = MBDEVICES[tonumber(r:value(4))]
      if mbd and not mbd[dunvno] then c8y:send('313,' .. r:value(2)) end
   end
end


function init()
   port = rdbGetInt(keyPort, 502)
   pollingRate = rdbGetInt(keyPollingRate, 30)
   transmitRate = rdbGetInt(keyTransmitRate, 3600)
   serPort, serBaud = rdbGetStr(keySerPort), rdbGetInt(keySerBaud, 19200)
   serData = rdbGetInt(keySerData, 8)
   serPar = rdbGetStr(keySerPar, 'E')
   serStop = rdbGetInt(keySerStop, 1)
   c8y:addMsgHandler(816, 'addDevice')
   c8y:addMsgHandler(817, 'saveConfigure')
   c8y:addMsgHandler(821, 'addCoil')
   c8y:addMsgHandler(822, 'addCoilAlarm')
   c8y:addMsgHandler(823, 'addCoilMeasurement')
   c8y:addMsgHandler(824, 'addCoilEvent')
   c8y:addMsgHandler(825, 'addRegister')
   c8y:addMsgHandler(826, 'addRegisterAlarm')
   c8y:addMsgHandler(827, 'addRegisterMeasurement')
   c8y:addMsgHandler(828, 'addRegisterEvent')
   c8y:addMsgHandler(829, 'setServerTime')
   c8y:addMsgHandler(830, 'addCoilStatus')
   c8y:addMsgHandler(831, 'addRegisterStatus')
   c8y:addMsgHandler(832, 'addDevice')
   c8y:addMsgHandler(833, 'setCoil')
   c8y:addMsgHandler(834, 'setRegister')
   c8y:addMsgHandler(835, 'clearCoilAlarm')
   c8y:addMsgHandler(836, 'clearRegisterAlarm')
   c8y:addMsgHandler(839, 'setmbtype')
   c8y:addMsgHandler(840, 'setmbtype')
   c8y:addMsgHandler(847, 'addDevice')
   c8y:addMsgHandler(848, 'addDevice')
   c8y:addMsgHandler(849, 'saveSerialConfiguration')
   c8y:addMsgHandler(851, 'clearAvailabilityAlarm')
   c8y:addMsgHandler(879, 'addRegisterEndian')
   c8y:addMsgHandler(862, 'addDevice')
   c8y:addMsgHandler(876, 'addDevice')
   c8y:addMsgHandler(863, 'saveConfigure')
   c8y:addMsgHandler(868, 'setCoil')
   c8y:addMsgHandler(869, 'setRegister')
   c8y:addMsgHandler(878, 'saveSerialConfiguration')

   timer0 = c8y:addTimer(1000, 'poll')
   timer1 = c8y:addTimer(5000, 'transmit')
   c8y:send(table.concat({'321', c8y.ID, pollingRate, transmitRate, 5}, ','))
   if rdbGetStr('uboot.hw_id') ~= 'NTC-140W-02' then
      c8y:send(table.concat({'335', c8y.ID, serBaud, serData,
                             serPar, serStop}, ','))
   end
   t0, t1 = os.time(), os.time()
   timer0:start()
   timer1:start()
   return 0
end


function addRegisterEndian(r)
   local mytbl = r:value(5) == 'false' and HR or IR
   local No, startBit = tonumber(r:value(2)), tonumber(r:value(3))
   local hint = {[no] = No, [rsbno] = startBit}
   local littleEndian = r:value(4) == 'true' and 1 or 0
   update(mytbl[DTYPE], hint, rleno, littleEndian, cmp2)
end
