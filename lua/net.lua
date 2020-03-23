require('myrdb')

local msisdn, isSMS
local subnetmasklist = {
   "128.0.0.0", "192.0.0.0", "224.0.0.0", "240.0.0.0",
   "248.0.0.0", "252.0.0.0", "254.0.0.0", "255.0.0.0",
   "255.128.0.0", "255.192.0.0", "255.224.0.0", "255.240.0.0",
   "255.248.0.0", "255.252.0.0", "255.254.0.0", "255.255.0.0",
   "255.255.128.0", "255.255.192.0", "255.255.224.0", "255.255.240.0",
   "255.255.248.0", "255.255.252.0", "255.255.254.0", "255.255.255.0",
   "255.255.255.128", "255.255.255.192", "255.255.255.224", "255.255.255.240",
   "255.255.255.248", "255.255.255.252"}
local monitorTimer
local networktbl = {}


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
   updateNetworkTable(networktbl)
   monitorTimer = c8y:addTimer(1*1000, 'configMonitor')
   monitorTimer:start()
   return 0
end


local function bitAND(a, b)
    local p, c = 1, 0
    while a > 0 and b > 0 do
        local ra, rb = a % 2, b % 2
        if ra + rb > 1 then c = c + p end
        a, b, p = (a - ra) / 2, (b - rb) / 2, p * 2
    end
    return c
end


local function bitOR(a, b)
    local p, c = 1, 0
    while a + b > 0 do
        local ra, rb = a % 2, b % 2
        if ra + rb > 0 then c = c + p end
        a, b, p = (a - ra) / 2, (b - rb) / 2, p * 2
    end
    return c
end


local function bitNOT(n)
    local p, c = 1, 0
    if n == 0 then return 255 end
    while n > 0 do
        local r = n % 2
        if r < 1 then c = c + p end
        n, p = (n - r) / 2, p * 2
    end
    return c
end


local function bitLshift(x, by)
  return x * 2 ^ by
end


local function isValidIPAddress(tbl)
   if tbl[1] > 255 or tbl[2] > 255 or tbl[3] > 255 or tbl[4] > 255
      or (tbl[1] == 0 and tbl[2] == 0 and tbl[3] == 0 and tbl[4] == 0) then
      return false
   end
   return true
end


local function hasValue(tbl, val)
   for i=1, #tbl do
      if tbl[i] == val then
         return true
      end
   end
   return false
end


local function divideAddr(ip)
   local tbl = {}
   tbl[1], tbl[2], tbl[3], tbl[4] = string.match(ip, "(%d+)%.(%d+)%.(%d+)%.(%d+)")
   tbl[1], tbl[2], tbl[3], tbl[4] = tonumber(tbl[1]), tonumber(tbl[2]), tonumber(tbl[3]), tonumber(tbl[4])
   return tbl
end


local function getAddrValue(tbl)
   return bitLshift(tbl[1], 24) + bitLshift(tbl[2], 16) + bitLshift(tbl[3], 8) + tbl[4]
end


local function getNetworkRange(t_ip, t_mask)
   local t_netstart, t_netend = {}, {}
   for i = 1, 4 do
      t_netstart[i] = bitAND(t_ip[i], t_mask[i])
      t_netend[i] = bitOR(t_ip[i], bitNOT(t_mask[i]))
   end
   return t_netstart, t_netend
end


local function getNewDHCPRange(t_dhcpstart, t_dhcpend, t_ip, t_mask, t_newip, t_newmask)
   local retstart, retend = table.concat(t_dhcpstart, '.'), table.concat(t_dhcpend, '.')
   local t_addrstart, t_addrend = getNetworkRange(t_ip, t_mask)
   local t_newaddrstart, t_newaddrend = getNetworkRange(t_newip, t_newmask)
   local availstart, availend = getAddrValue(t_addrstart) + 1, getAddrValue(t_addrend) - 1
   local newavailstart, newavailend = getAddrValue(t_newaddrstart) + 1, getAddrValue(t_newaddrend) - 1
   local dhcpstart, dhcpend = getAddrValue(t_dhcpstart), getAddrValue(t_dhcpend)

   if dhcpstart < newavailstart or newavailend < dhcpend then
      srInfo('The current DHCP range is out of network range. Going to update')
      local numhosts = newavailend - newavailstart + 1
      local s, e
      if numhosts > 100 then
         s = t_newip[4] + 100 < 254 and t_newip[4] + 1 or t_newip[4] - 100
         e = t_newip[4] + 100 < 254 and t_newip[4] + 100 or t_newip[4] - 1
      else
         s = t_newip[4] + 100 < 254 and t_newip[4] + 1 or t_newip[4] - numhosts + 1
         e = t_newip[4] + 100 < 254 and t_newip[4] + numhosts - 1 or t_newip[4] - 1
      end
      retstart = t_newaddrstart[1] .. '.' .. t_newaddrstart[2] .. '.' .. t_newaddrstart[3] .. '.' .. tonumber(s)
      retend = t_newaddrstart[1] .. '.' .. t_newaddrstart[2] .. '.' .. t_newaddrstart[3] .. '.' .. tonumber(e)
      srDebug('New DHCP range ' .. retstart .. ' to ' .. retend)
   end

   return retstart, retend
end


local function isNewDHCPWithinRange(t_dhcpstart, t_dhcpend, t_ip, t_mask, t_newdhcpstart, t_newdhcpend)
   local t_addrstart, t_addrend = getNetworkRange(t_ip, t_mask)
   local availstart, availend = getAddrValue(t_addrstart) + 1, getAddrValue(t_addrend) - 1
   local dhcpstart, dhcpend = getAddrValue(t_dhcpstart), getAddrValue(t_dhcpend)
   local newdhcpstart, newdhcpend = getAddrValue(t_newdhcpstart), getAddrValue(t_newdhcpend)
   local numhosts = availend - availstart + 1
   if newdhcpstart > newdhcpend then
      srError('DHCP start address must be smaller than DHCP end address')
      return false
   end
   if newdhcpend - newdhcpstart > numhosts
      or newdhcpstart < availstart or availend < newdhcpend then
      srError('DHCP range is out of network range')
      return false
   end
   return true
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
   local lan = (rdbGetStr("network.interface.eth.0.mode") == "") and "0" or "1"
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
   local rdblanip = rdbGetStr("link.profile.0.address")
   local rdbnetmask = rdbGetStr("link.profile.0.netmask")
   local rangekey = "service.dhcp.range.0"
   local rdbdhcpstart, rdbdhcpend = rdbGetStr(rangekey):match("([^,]+),([^,]+)")

   local t_lanip, t_subnet = divideAddr(rdblanip), divideAddr(rdbnetmask)

   if rdblanip ~= r:value(3) or rdbnetmask ~= r:value(4) then
      local t_newlanip, t_newsubnet = divideAddr(r:value(3)), divideAddr(r:value(4))
      if not isValidIPAddress(t_newlanip) then
         c8y:send('304,' .. r:value(2) .. ',"LAN IP is invalid"', 1)
         return
      end
      if not hasValue(subnetmasklist, r:value(4)) then
         c8y:send('304,' .. r:value(2) .. ',"Subnet mask is invalid"', 1)
         return
      end
      local t_dhcpstart, t_dhcpend = divideAddr(rdbdhcpstart), divideAddr(rdbdhcpend)
      local newdhcpstart, newdhcpend = getNewDHCPRange(t_dhcpstart, t_dhcpend, t_lanip, t_subnet, t_newlanip, t_newsubnet)
      rdbSet('link.profile.0.address', r:value(3))
      rdbSet('link.profile.0.netmask', r:value(4))
      rdbSet('service.dhcp.range.0', newdhcpstart .. ',' .. newdhcpend)
   end

   if r:value(5) == '0' then
      rdbSet('network.interface.eth.0.mode', '')
      rdbSet('network.interface.trigger', '1')
   elseif r:value(5) == '1' then
      rdbSet('network.interface.eth.0.mode', 'lan')
      rdbSet('network.interface.trigger', '1')
   end
   c8y:send('303,' .. r:value(2) .. ',SUCCESSFUL', 1)
   updateNetwork()
end


function configDHCP(r)
   local rdblanip = rdbGetStr("link.profile.0.address")
   local rdbnetmask = rdbGetStr("link.profile.0.netmask")
   local rangekey = "service.dhcp.range.0"
   local rdbdhcpstart, rdbdhcpend = rdbGetStr(rangekey):match("([^,]+),([^,]+)")

   if rdbdhcpstart ~= r:value(3) or rdbdhcpend ~= r:value(4) then
      local t_lanip, t_subnet = divideAddr(rdblanip), divideAddr(rdbnetmask)
      local t_dhcpstart, t_dhcpend = divideAddr(rdbdhcpstart), divideAddr(rdbdhcpend)
      local t_newdhcpstart, t_newdhcpend = divideAddr(r:value(3)), divideAddr(r:value(4))
      if not isNewDHCPWithinRange(t_dhcpstart, t_dhcpend, t_lanip, t_subnet, t_newdhcpstart, t_newdhcpend) then
         c8y:send('304,' .. r:value(2) .. ',"DHCP range is invalid"', 1)
         return
      end
   end

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


function updateNetworkTable(tbl)
   tbl["simstatus"] = rdbGetStr("wwan.0.sim.status.status")
   tbl["apn"] = rdbGetStr("link.profile.1.apn")
   tbl["user"] = rdbGetStr("link.profile.1.user")
   tbl["pass"] = rdbGetStr("link.profile.1.pass")
   tbl["auth"] = rdbGetStr("link.profile.1.auth_type")
   tbl["wanip"] = rdbGetStr("link.profile.1.iplocal")
   tbl["lanip"] = rdbGetStr("link.profile.0.address")
   tbl["netmask"] = rdbGetStr("link.profile.0.netmask")
   tbl["lan"] = rdbGetStr("network.interface.eth.0.mode")
   local rangekey = "service.dhcp.range.0"
   tbl["addrstart"], tbl["addrend"] = rdbGetStr(rangekey):match("([^,]+),([^,]+)")
   tbl["dns1"] = rdbGetStr("service.dhcp.dns1.0")
   tbl["dns2"] = rdbGetStr("service.dhcp.dns2.0")
   tbl["domain"] = rdbGetStr("service.dhcp.suffix.0")
   tbl["dhcp"] = rdbGetInt("service.dhcp.enable")
end


function configMonitor()
   local tbl = {}
   updateNetworkTable(tbl)
   for key in pairs(tbl) do
      if tbl[key] ~= networktbl[key] then
         updateNetworkTable(networktbl)
         updateNetwork()
         return
      end
   end
end
