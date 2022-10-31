#!/bin/bash

# ssh into instance

sudo yum update
sudo amazon-linux-extras install java-openjdk11

# download and extract kafka and move directory to /opt
wget https://downloads.apache.org/kafka/3.3.1/kafka_2.13-3.3.1.tgz
sudo mkdir /opt/kafka
sudo tar xzf kafka_2.13-3.3.1.tgz -C /opt/kafka --strip-components=1
rm kafka_2.13-3.3.1.tgz
 
cd /etc/systemd/system 
sudo touch zookeeper.service kafka.service

# now add the following to the zookeeper service 
sudo nano zookeeper.service

[Unit]
Description=Apache Zookeeper 
Requires=network.target remote-fs.target
After=network.target remote-fs.target

[Service]
Type=simple
ExecStart=/opt/kafka/bin/zookeeper-server-start.sh /opt/kafka/config/zookeeper.properties
ExecStop=/opt/kafka/bin/zookeeper-server-stop.sh
Restart=on-abnormal

[Install]
WantedBy=multi-user.target

# now add the following to the kafka service
sudo nano kafka.service

[Unit]
Description=Apache Kafka Server (Broker)
After=zookeeper.service

[Service]
Type=simple
ExecStart=/opt/kafka/bin/kafka-server-start.sh /opt/kafka/config/server.properties
ExecStop=/opt/kafka/bin/kafka-server-stop.sh
Restart=no 

[Install]
WantedBy=multi-user.target

# now reload systemctl, enable and start both services
sudo systemctl daemon-reload 
sudo systemctl enable zookeeper
sudo systemctl enable kafka
sudo systemctl start zookeeper
sudo systemctl start kafka

# since we're on a free micro instance, you now need to edit memory allocation to get things running
sudo nano ~/.bashrc

export KAFKA_HEAP_OPTS=-Xms32M
export ZK_CLIENT_HEAP=128, ZK_SERVER_HEAP=128

# then edit your kafka and zookeeper server start files to use less memory. Applicable to micro and small t2:
sudo nano /opt/kafka/bin/zookeeper-server-start.sh 

# change KAFKA_HEAD_OPTS to
export KAFKA_HEAP_OPTS="-Xms32M -Xmx64M"

sudo nano /opt/kafka/bin/kafka-server-start.sh 
export KAFKA_HEAP_OPTS="-Xms32M -Xmx64M"

# exit the ssh connection and re-enter. Then run
sudo systemctl restart zookeeper
sudo systemctl restart kafka 

# a quick creation of a topic and then list that topics messages
/opt/kafka/bin/kafka-topics.sh --create --topic first-topic --bootstrap-server localhost:9092

# open a new terminal and write to thate topic in a consumer. Open a console consumer in the first terminal
/opt/kafka/bin/kafka-console-consumer.sh --bootstrap-server localhost:9092 --topic first-topic
/opt/kafka/bin/kafka-console-producer.sh --bootstrap-server localhost:9092 --topic first-topic

# post a few messages and they should show up when you kill those and list topic and messages
/opt/kafka/bin/kafka-console-consumer.sh --bootstrap-server localhost:9092 --topic first-topic --from-beginning

# now configure zookeeper 
sudo mkdir /opt/kafka/ssl
cd /opt/kafka/ssl

# generate a key and cert used for all operations thereafter
openssl req -new -x509 -keyout ca-key -out ca-cert -days 365

# zookeeper
keytool -keystore kafka.zookeeper.truststore.jks -alias ca-cert -import -file ca-cert
keytool -keystore kafka.zookeeper.keystore.jks -alias zookeeper -validity 365 -genkey -keyalg RSA -ex SAN=dns:localhost
keytool -keystore kafka.zookeeper.keystore.jks -alias zookeeper -certreq -file ca-request-zookeeper
openssl x509 -req -CA ca-cert -CAKey ca-key -in ca-request-zookeeper -out ca-signed-zookeeper -days 365 -CAcreateserial
keytool -keystore kafka.zookeeper.keystore.jks -alias ca-cert -import -file ca-cert 
keytool -keystore kafka.zookeeper.keystore.jks -alias zookeeper -import -file ca-signed-zookeeper

# then add the following to zookeeper.properties

# zookeeper client
keytool -keystore kafka.zookeeper-client.truststore.jks -alias ca-cert -import -file ca-cert
keytool -keystore kafka.zookeeper-client.keystore.jks -alias zookeeper-client -validity 365 -genkey -keyalg RSA -ex SAN=dns:localhost
keytool -keystore kafka.zookeeper-client.keystore.jks -alias zookeeper-client -certreq -file ca-request-zookeeper-client
openssl x509 -req -CA ca-cert -CAKey ca-key -in ca-request-zookeeper-client -out ca-signed-zookeeper-client -days 365 -CAcreateserial
keytool -keystore kafka.zookeeper-client.keystore.jks -alias ca-cert -import -file ca-cert 
keytool -keystore kafka.zookeeper-client.keystore.jks -alias zookeeper-client -import -file ca-signed-zookeeper-client

# for your broker (repeat for each one)
keytool -keystore kafka.broker0.truststore.jks -alias ca-cert -import -file ca-cert
keytool -keystore kafka.broker0.keystore.jks -alias broker0 -validity 365 -genkey -keyalg RSA -ex SAN=dns:localhost
keytool -keystore kafka.broker0.keystore.jks -alias broker0 -certreq -file ca-request-broker0
openssl x509 -req -CA ca-cert -CAKey ca-key -in ca-request-broker0 -out ca-signed-broker0 -days 365 -CAcreateserial
keytool -keystore kafka.broker0.keystore.jks -alias ca-cert -import -file ca-cert 
keytool -keystore kafka.broker0.keystore.jks -alias broker0 -import -file ca-signed-broker0

# for producer
keytool -keystore kafka.producer.truststore.jks -alias ca-cert -import -file ca-cert
keytool -keystore kafka.producer.keystore.jks -alias producer -validity 365 -genkey -keyalg RSA -ex SAN=dns:localhost
keytool -keystore kafka.producer.keystore.jks -alias producer -certreq -file ca-request-producer
openssl x509 -req -CA ca-cert -CAKey ca-key -in ca-request-producer -out ca-signed-producer -days 365 -CAcreateserial
keytool -keystore kafka.producer.keystore.jks -alias ca-cert -import -file ca-cert 
keytool -keystore kafka.producer.keystore.jks -alias producer -import -file ca-signed-producer

# for consumer
keytool -keystore kafka.consumer.truststore.jks -alias ca-cert -import -file ca-cert
keytool -keystore kafka.consumer.keystore.jks -alias consumer -validity 365 -genkey -keyalg RSA -ex SAN=dns:localhost
keytool -keystore kafka.consumer.keystore.jks -alias consumer -certreq -file ca-request-consumer
openssl x509 -req -CA ca-cert -CAKey ca-key -in ca-request-consumer -out ca-signed-consumer -days 365 -CAcreateserial
keytool -keystore kafka.consumer.keystore.jks -alias ca-cert -import -file ca-cert 
keytool -keystore kafka.consumer.keystore.jks -alias consumer -import -file ca-signed-consumer
