#!/bin/bash

sudo su 
yum update
amazon-linux-extras install java-openjdk11

# download and extract kafka and move directory to /opt
wget https://downloads.apache.org/kafka/3.3.1/kafka_2.13-3.3.1.tgz
mkdir /opt/kafka
tar xzf kafka_2.13-3.3.1.tgz -C /opt/kafka --strip-components=1
rm kafka_2.13-3.3.1.tgz
 
cd /etc/systemd/system 
touch zookeeper.service kafka.service

# now add the following to the zookeeper service 
nano zookeeper.service

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
nano kafka.service

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
systemctl daemon-reload 
systemctl enable zookeeper
systemctl enable kafka
systemctl start zookeeper
systemctl start kafka

exit 
# a quick creation of a topic and then list that topics messages
/opt/kafka/bin/kafka-topics.sh --create --topic first-topic --bootstrap-server localhost:9092

# open a new terminal and write to thate topic in a consumer. Open a console consumer in the first terminal
/opt/kafka/bin/kafka-console-consumer.sh --bootstrap-server localhost:9092 --topic first-topic
/opt/kafka/bin/kafka-console-producer.sh --bootstrap-server localhost:9092 --topic first-topic

# post a few messages and they should show up when you kill those and list topic and messages
/opt/kafka/bin/kafka-console-consumer.sh --bootstrap-server localhost:9092 --topic first-topic --from-beginning
