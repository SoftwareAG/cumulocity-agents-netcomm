require('myrdb')

local msisdn, isSMS

function init()
   c8y:addMsgHandler(806, 'updateMsisdn')
   c8y:addMsgHandler(812, 'updateMobile')
   c8y:addMsgHandler(818, 'configWAN')
   c8y:addMsgHandler(819, 'configLAN')
   c8y:addMsgHandler(820, 'configDHCP')
   c8y:addMsgHandler(852, 'setDeliveryType')

   c8y:addMsgHandler(864, 'setDeliveryType')
   c8y:addMsgHandler(865, 'configWAN')
   c8y:addMsgHandler(866, 'configLAN')
   c8y:addMsgHandler(867, 'configDHCP')
   updateNetwork()
   c8y:send('309,' .. c8y.ID)
   return 0
end


function updateMsisdn(r)
   if r.size > 2 and r:value(2) ~= "" then msisdn = r:value(2) end
end


local function _updateMobile(msisdn)
   local cell = rdbGetInt("wwan.0.system_network_status.CellID")
   local mcc = rdbGetInt("wwan.0.system_network_status.MCC")
   local imei = rdbGetStr("wwan.0.imei")
   local iccid = rdbGetStr("wwan.0.system_network_status.simICCID")
   local mnc = rdbGetInt("wwan.0.system_network_status.MNC")
   local imsi = rdbGetStr("wwan.0.imsi.msin")
   local lac = tonumber(rdbGetStr("wwan.0.system_network_status.LAC"), 16) or ''
   local conn = rdbGetStr("wwan.0.conn_type")
   local operator = rdbGetStr("wwan.0.system_network_status.network.unencoded")
   local band = rdbGetStr("wwan.0.system_network_status.current_band")
   local type = rdbGetStr("wwan.0.system_network_status.system_mode")
   if type == 'LTE' then
      local rsrp = rdbGetInt("wwan.0.radio.information.signal_strength")
      local rsrq = rdbGetInt('wwan.0.signal.rsrq')
      c8y:send(table.concat({'306', c8y.ID, cell, mcc, imei, iccid, mnc, imsi, lac,
                          msisdn, conn, operator, band, rsrp, rsrq}, ','))
   elseif type == 'UMTS' then
      local rscp = rdbGetInt("wwan.0.radio.information.signal_strength")
      c8y:send(table.concat({'337', c8y.ID, cell, mcc, imei, iccid, mnc, imsi, lac,
                          msisdn, conn, operator, band, rscp}, ','))
   elseif type == 'GSM' then
      local rssi = rdbGetInt("wwan.0.radio.information.signal_strength")
      c8y:send(table.concat({'338', c8y.ID, cell, mcc, imei, iccid, mnc, imsi, lac,
                          msisdn, conn, operator, band, rssi}, ','))
   end
end


function updateMobile()
   if not msisdn then msisdn = rdbGetStr("wwan.0.sim.data.msisdn") end
   _updateMobile(msisdn)
end


function updateNetwork()
   local simstatus = rdbGetStr("wwan.0.sim.status.status")
   local apn = rdbGetStr("link.profile.1.apn")
   local user = rdbGetStr("link.profile.1.user")
   local pass = rdbGetStr("link.profile.1.pass")
   local auth = rdbGetStr("link.profile.1.auth_type")
   local wanip = rdbGetStr("link.profile.1.iplocal")
   local name = "br0"
   local mac = rdbGetStr("systeminfo.mac.eth0")
   local lanip = rdbGetStr("link.profile.0.address")
   local netmask = rdbGetStr("link.profile.0.netmask")
   local lan = "1"
   local rangekey = "service.dhcp.range.0"
   local addrstart, addrend = rdbGetStr(rangekey):match("([^,]+),([^,]+)")
   local dns1 = rdbGetStr("service.dhcp.dns1.0")
   local dns2 = rdbGetStr("service.dhcp.dns2.0")
   local domain = rdbGetStr("service.dhcp.suffix.0")
   local dhcp = rdbGetInt("service.dhcp.enable")
   c8y:send(table.concat({'305', c8y.ID, simstatus, apn, user, pass, auth,
                          wanip, name, mac, lanip, netmask, lan, addrstart,
                          addrend, dns1, dns2, domain, dhcp}, ','))
end


function configWAN(r)
   if not isSMS then
      rdbSet('link.profile.1.apn', r:value(3))
      rdbSet('link.profile.1.user', r:value(4))
      rdbSet('link.profile.1.pass', r:value(5))
      rdbSet('link.profile.1.auth_type', r:value(6))
      updateNetwork()
      c8y:send('303,' .. r:value(2) .. ',SUCCESSFUL', 1)
   end
   isSMS = false
end


function configLAN(r)
   rdbSet('link.profile.0.address', r:value(3))
   rdbSet('link.profile.0.netmask', r:value(4))
   c8y:send('303,' .. r:value(2) .. ',SUCCESSFUL', 1)
   updateNetwork()
end


function configDHCP(r)
   rdbSet('service.dhcp.range.0', r:value(3) .. ',' .. r:value(4))
   rdbSet('service.dhcp.dns1.0', r:value(5))
   rdbSet('service.dhcp.dns2.0', r:value(6))
   rdbSet('service.dhcp.suffix.0', r:value(7))
   rdbSet('service.dhcp.enable', r:value(8))
   c8y:send('303,' .. r:value(2) .. ',SUCCESSFUL', 1)
   updateNetwork()
end


function setDeliveryType(r)
   isSMS = r:value(2) == 'SMS'
end
