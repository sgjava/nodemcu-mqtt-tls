function wifi_start(ip, netmask, gateway, ssid, pwd, callback)
  wifi.setmode(wifi.STATION)
  wifi.sta.setip {ip=ip, netmask=netmask, gateway=gateway}
  wifi.sta.config {ssid=ssid, pwd=pwd}
  wifi.sta.sethostname("node-" .. string.format("%x", node.chipid()))
  wifi.sta.connect()
  tmr.alarm(1,1000,1,function()
    if wifi.sta.getip()==nil then
      print("Waiting for IP")
    else
      tmr.stop(1)
      print("hostname: "..wifi.sta.gethostname())
      print("ip: "..wifi.sta.getip())
      callback()
    end
  end)
end
