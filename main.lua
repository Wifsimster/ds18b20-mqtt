require('config')

TOPIC = "/sensors/bureau/bs18b20/data"

function readData() 
  ds18b20 = require('ds18b20')
  ds18b20.setup(DATA_PIN)
  data = ds18b20.read()
  -- Release it after use
  ds18b20 = nil
  package.loaded["ds18b20"] = nil
  return data
end

-- Init client with keepalive timer 120sec
m = mqtt.Client(CLIENT_ID, 120, "", "")

tmr.alarm(2, 1000, 1, function()
    tmr.stop(2)
    print("Connecting to MQTT: "..BROKER_IP..":"..BROKER_PORT.."...")
    m:connect(BROKER_IP, BROKER_PORT, 0, function(conn)
        print("Connected to MQTT: "..BROKER_IP..":"..BROKER_PORT.." as "..CLIENT_ID)
        TEMP = readData()

        -- Publish a first time the data
        DATA = '{"temp":"'..TEMP..'"}'
        m:publish(TOPIC, DATA, 0, 0, function(conn)
            print(CLIENT_ID.." sending data: "..DATA.." to "..TOPIC)
          end)

        -- Check every 5s for values change
        tmr.alarm(1, REFRESH_RATE, 1, function()
          TMP_TEMP = readData()
            if(TEMP ~= TMP_TEMP or PRES ~= TMP_PRES) then
              DATA = '{"temp":"'..TMP_TEMP..'"}'
              -- Publish a message (QoS = 0, retain = 0)
              m:publish(TOPIC, DATA, 0, 0, function(conn)
                  print(CLIENT_ID.." sending data: "..DATA.." to "..TOPIC)
                end)
            else
              print("No change in value, no data send to broker.")
            end
          end)
      end)
  end)

m:close();
