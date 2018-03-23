--- Connect to wifi in station mode with retry.
-- @param ip number: Static IP address.
-- @param netmask string: Netmask for this IP.
-- @param gateway string: AP gateway.
-- @param ssid string: AP SSID.
-- @param pwd string: AP password.
-- @param callback function: Callback after connection established.
function wifi_connect(ip, netmask, gateway, ssid, pwd, callback)
  wifi.setmode(wifi.STATION)
  wifi.sta.setip {ip=ip, netmask=netmask, gateway=gateway}
  wifi.sta.config {ssid=ssid, pwd=pwd}
  -- hostname is node-node.chipid()
  -- node-000000 is an example
  wifi.sta.sethostname("node-" .. string.format("%x", node.chipid()))
  wifi.sta.connect()
  -- Retry every second
  tmr.alarm(1,1000,tmr.ALARM_AUTO,function()
    if wifi.sta.getip()==nil then
      print("Waiting for IP")
    else
      tmr.stop(1)
      print("hostname: "..wifi.sta.gethostname())
      print("ip: "..wifi.sta.getip())
      -- We're connected, so do callback
      callback()
    end
  end)
end
