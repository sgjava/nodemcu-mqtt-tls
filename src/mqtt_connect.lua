--- Create MQTT client.
-- @param client_id string: hostname is used, but could be anything.
-- @param keep_alive number: Keep alive timer in seconds.
-- @param user string: Broker user.
-- @param password string: Broker password.
function mqtt_client(client_id, keep_alive, user, password)
  m_client = mqtt.Client(client_id, keep_alive, user, password)
  m_client:on("connect", function(client) print ("connected") end)
  -- Try to connect if client goes offline
  m_client:on("offline", function(client)
    print ("offline")
    m_client:close()
    mqtt_connect(mqtt_host, mqtt_port, mqtt_topic_in, mqtt_topic_out)
  end)
end

--- Connect MQTT client with retry.
-- @param host string: Broker hostname.
-- @param port number: Broker port.
-- @param topic string: Broker topic.
function mqtt_connect(host, port, topic)
  tmr.alarm(1, 3000, tmr.ALARM_AUTO, function()
    m_client:close()
    m_client:connect(host, port, 1, function(client)
      client:subscribe(topic, 0, function(client) print("subscribed to " .. topic) end)
      tmr.stop(1)
    end,
    function(client, reason)
      print("failed reason: " .. reason)
    end)
  end)
end
