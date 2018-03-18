![Title](images/title.png)

![ESP8266 LoLin V3 NodeMCU](images/esp8266.png)
How to configure NodeMCU to use MQTT with TLS encryption. The broker will be
installed on Ubuntu 16.04 server, but you should be able to configure MQTT
broker on other distributions.

I explored HTTPS, but this is not working with the HTTP module in the NodeMCU
dev branch. In any event the TLS module uses quite a bit of memory, so you must
be judicious as you add additional code on the ESP8266.

## Configure MQTT broker
I'm using a Ubuntu 16.04 server via VirtualBox to create the broker. Eventually
this would be installed on a SBC like a NanoPi Duo to handle messages 24/7 with
your connected IoT devices. Note this example uses onl server certificate. You
can use client certificates to validate calling client.
* Start with fresh Ubuntu 16.04 server install and apply all upgrades.
* Install Mosquitto broker and clients
    * `sudo apt-get install mosquitto mosquitto-clients git-core`
* Open terminal subscribe to topic
    * `mosquitto_sub -h localhost -t test`
* Open terminal publish to topic
    * `mosquitto_pub -h localhost -t test -m "hello test"`
    * You should see message on terminal running mosquitto_sub
    * Press Ctrl-C on terminal running mosquitto_sub
* Create CA and server certificates. I'm using a [generate-CA.sh](https://github.com/owntracks/tools/raw/master/TLS/generate-CA.sh)
script, but I've included a copy [locally](https://raw.githubusercontent.com/sgjava/nodemcu-mqtt-tls/master/scripts/generate-CA.sh) in case it dissapairs. 
    * `wget https://raw.githubusercontent.com/sgjava/nodemcu-mqtt-tls/master/scripts/generate-CA.sh`
    * `chmod a+x generate-CA.sh`
    * `./generate-CA.sh`
* Copy generated CA
    * `sudo cp ca.crt /etc/mosquitto/ca_certificates/.`
* Copy generated certs (use actual file names which are prefixed by hostname)
    * `sudo cp myhost.crt myhost.key /etc/mosquitto/certs/.`
* Configure mosquitto for SSL (use actual finel names for certs)
    * `sudo nano /etc/mosquitto/conf.d/default.conf`
    ```# Plain MQTT protocol
    listener 1883

    # End of plain MQTT configuration

    # MQTT over TLS/SSL
    listener 8883
    cafile /etc/mosquitto/ca_certificates/ca.crt
    certfile /etc/mosquitto/certs/myhost.crt
    keyfile /etc/mosquitto/certs/myhost.key

    # End of MQTT over TLS/SLL configuration
```
* `sudo service mosquitto restart`
* Open terminal subscribe to topic
    * `mosquitto_sub -h localhost -t test -p 8883 --cafile /etc/mosquitto/ca_certificates/ca.crt`
* Open terminal publish to topic
    * `mosquitto_pub -h localhost -t test -m "hello ssl" -p 8883 --cafile /etc/mosquitto/ca_certificates/ca.crt`
    * You should see message on terminal running mosquitto_sub
    * Press Ctrl-C on terminal running mosquitto_sub

## Configure NodeMCU
[Flash](https://github.com/sgjava/nodemcu-lolin) your ESP8266 with latest
NodeMCU dev branch. Select MQTT and TLS modules with automated build.



