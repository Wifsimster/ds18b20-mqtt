require('config')

TOPIC = "/sensors/bs18b20/data"

function readData() 
  local ds18b20 = require('ds18b20')
  ds18b20.setup(DATA_PIN)
  local data = ds18b20.read()
  -- Release it after use
  ds18b20 = nil
  package.loaded["ds18b20"] = nil
  data = tonumber(string.format("%02.1f", data))
  return data
end

-- Init client with keepalive timer 120sec
m = mqtt.Client(CLIENT_ID, 120, "", "")

ip = wifi.sta.getip()

m:lwt("/offline", '{"message":"'..CLIENT_ID..'", "topic":"'..TOPIC..'", "ip":"'..ip..'"}', 0, 0)
            
print("Connecting to MQTT: "..BROKER_IP..":"..BROKER_PORT.."...")
m:connect(BROKER_IP, BROKER_PORT, 0, 1, function(conn)
    print("Connected to MQTT: "..BROKER_IP..":"..BROKER_PORT.." as "..CLIENT_ID)

    local temperature = readData()
        if(temperature < 80) then
            DATA = '{"mac":"'..wifi.sta.getmac()..'","ip":"'..ip..'","refresh":"'..REFRESH_RATE..'",'
            DATA = DATA..'"temperature":"'..temperature..'"}'              
            m:publish(TOPIC, DATA, 0, 0, function(conn)
                print(CLIENT_ID.." sending data: "..DATA.." to "..TOPIC)
            end)
        collectgarbage()
        end
        
    tmr.alarm(1, REFRESH_RATE, 1, function()
       local temperature = readData()
        if(temperature < 80) then
            DATA = '{"mac":"'..wifi.sta.getmac()..'","ip":"'..ip..'","refresh":"'..REFRESH_RATE..'",'
            DATA = DATA..'"temperature":"'..temperature..'"}'              
            m:publish(TOPIC, DATA, 0, 0, function(conn)
                print(CLIENT_ID.." sending data: "..DATA.." to "..TOPIC)
            end)
        collectgarbage()
    end
  end)
end)
