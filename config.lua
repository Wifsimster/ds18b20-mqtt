-- Wifi
AP = ""
PWD = ""

-- MQTT Broker
BROKER_IP = "192.168.0.X"
BROKER_PORT = 1883
CLIENT_ID = "ESP8266-"..node.chipid()
REFRESH_RATE = 30000 -- ms

-- GPIO
DATA_PIN = 3 -- GPIO_0

-- SENSOR LOCATION
LOCATION = "bedroom"