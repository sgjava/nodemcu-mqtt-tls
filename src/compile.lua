node.compile("config.lua")
file.remove("config.lua")
node.compile("wifi_connect.lua")
file.remove("wifi_connect.lua")
node.compile("mqtt_connect.lua")
file.remove("mqtt_connect.lua")
node.compile("main.lua")
file.remove("main.lua")
for k,v in pairs(file.list()) do print(k.." ("..v.." bytes)") end