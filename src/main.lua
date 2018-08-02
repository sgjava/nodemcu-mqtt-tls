-- This is the main module. Use init.lua to auto start this module.
--
-- main.lua connects to wifi first. If that works then MQTT broker connection
-- is established. If all goes well you should see "subscribed to node-000000-in".
-- Now you can send commands to the devices input topic such as:
--
-- Echo hello to devices console:
--
-- echo:hello

-- Turn LED connected to pin 1 (D1) on:
--
-- gpio_write:1,0
--
-- Use mosquitto client to test on broker:
--
-- mosquitto_pub -h localhost -t node-000000-in -m "echo:hello" -p 8883 --cafile /etc/mosquitto/ca_certificates/ca.crt -u <user_name> -P <password>

require "config"
require "wifi_connect"
require "mqtt_connect"

--- Write to GPIO pin.
-- @param client mqtt.Client: MQTT client.
-- @param params table: First parameter is the pin number and the second is
-- the value to set the pin to.
-- @param data string: Raw command string.
function gpio_write(client, params, data)
  gpio.write(params[1], params[2])
  -- Send output topic hostname:data
  client:publish(mqtt_topic_out, wifi.sta.gethostname() .. ":OK:" .. data, 0, 0)
end

-- Commands mapped to function.
command = {
  ["echo"] = function (client, params, data) print(params[1]) end,
  ["gpio_write"] = gpio_write,
}

--- Write to GPIO pin.
-- @param str string: String to parse.
-- @return table: Table of split values.
function split(str, delim)
  local words = {}
  for x in string.gmatch(str, '([^' .. delim .. ']+)') do
    table.insert(words, x)
  end
  return words
end

--- mqtt.Client message callback for input topic. Parses payload into command
-- and parameters. The format is command:param1,param2, ... The command table
-- is used to map to functions. Think of it as a poor man's command pattern.
-- If the command is found in the command table then it is executed.
-- @param client mqtt.Client: MQTT client.
-- @param topic string: Broker topic.
-- @param data string: Raw command string.
function mqtt_message(client, topic, data)
  if data ~= nil then
    -- Parse payload into command and params
    local words = split(data, ':')
    if command[words[1]] ~= nil then
      -- Call function with params parsed into a table
      command[words[1]](client, split(words[2], ','), data)
    else
      -- Unknown command
      client:publish(mqtt_topic_out, wifi.sta.gethostname() .. ":" .. words[1] .. ":ERROR:Command not found", 0, 0)
    end
  else
    -- nil payload
    client:publish(mqtt_topic_out, wifi.sta.gethostname() .. ":ERROR:nil message", 0, 0)
  end
end

--- wifi_connect callback after wifi connection established. Broker
-- connection is attempted next. Set mqtt.Client message callback to
-- mqtt_message.
function wifi_started()
  mqtt_topic_in = wifi.sta.gethostname() .. "-in"
  -- Only create mqtt.Client once
  if m_client == nil then
    mqtt_client(wifi.sta.gethostname(), mqtt_keepalive, mqtt_user, mqtt_password)
  end
  mqtt_connect(mqtt_host, mqtt_port, mqtt_topic_in)
  m_client:on("message", mqtt_message)
end

-- Connect to wifi
wifi_connect(wifi_ip, wifi_netmask, wifi_gateway, wifi_ssid, wifi_pwd, wifi_started)
