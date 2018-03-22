require "config"
require "wifi_connect"
require "mqtt_connect"

function gpio_write(client, params)
  gpio.write(params[1], params[2])
  client:publish(mqtt_topic_out, wifi.sta.gethostname() .. ":gpio_write:OK", 0, 0)
end

action = {
  ["echo"] = function (client, params) print(params[1]) end,
  ["gpio_write"] = gpio_write,
}

function split(str, delim)
  local words = {}
  for x in string.gmatch(str, '([^' .. delim .. ']+)') do
    table.insert(words, x)
  end
  return words
end

function mqtt_message(client, topic, data)
  if data ~= nil then
    local words = split(data, ':')
    if action[words[1]] ~= nil then
      action[words[1]](client, split(words[2], ','))
    else
      client:publish(mqtt_topic_out, wifi.sta.gethostname() .. ":" .. words[1] .. ":not found", 0, 0)
    end
  else
    print("nil message")
  end
end

function wifi_started()
  mqtt_topic_in = wifi.sta.gethostname() .. "-in"
  mqtt_client(wifi.sta.gethostname(), mqtt_keepalive, mqtt_user, mqtt_password)
  mqtt_connect(mqtt_host, mqtt_port, mqtt_topic_in)
  mqttClient:on("message", mqtt_message)
end

wifi_start(wifi_ip, wifi_netmask, wifi_gateway, wifi_ssid, wifi_pwd, wifi_started)
