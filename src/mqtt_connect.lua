function mqtt_client(clientId, keepalive, user, password)
  mqttClient = mqtt.Client(clientId, keepalive, user, password)
  mqttClient:on("connect", function(client) print ("connected") end)
  mqttClient:on("offline", function(client)
    print ("offline")
    mqttClient:close()
    mqtt_connect(mqtt_host, mqtt_port, mqtt_topic_in, mqtt_topic_out)
  end)
end

function mqtt_connect(host, port, topic)
  tmr.alarm(1, 3000, tmr.ALARM_SEMI, function()
    mqttClient:close()
    mqttClient:connect(host, port, 1, function(client)
      client:subscribe(topic, 0, function(client) print("subscribed to " .. topic) end)
      tmr.stop(1)
    end,
    function(client, reason)
      print("failed reason: " .. reason)
      tmr.start(1)
    end)
  end)
end