#!/bin/bash

sudo apt-get update
# install java
sudo apt install default-jre

# download and extract kafka and move directory to /opt
wget https://downloads.apache.org/kafka/3.3.1/kafka_2.13-3.3.1.tgz
sudo mkdir /opt/kafka
sudo tar xzf kafka_2.13-3.3.1.tgz -C /opt/kafka --strip-components=1
rm kafka_2.13-3.3.1.tgz

# configure kafka and zookeeper as services
sudo cp zookeeper.service /etc/systemd/system/zookeeper.service
sudo cp kafka.service /etc/systemd/system/kafka.service
# now reload the systemctl manager and enable and start both services

sudo systemctl daemon-reload 

sudo systemctl start zookeeper
sudo systemctl enable zookeeper

sudo systemctl start kafka
sudo systemctl enable kafka

# reload zookeeper service
sudo systemctl restart zookeeper

# a quick creation of a topic and then list that topics messages
/opt/kafka/bin/kafka-topics.sh --create --topic first-topic --bootstrap-server localhost:9092

# open a new terminal and write to thate topic in a consumer. Open a console consumer in the first terminal
/opt/kafka/bin/kafka-console-consumer.sh --bootstrap-server localhost:9092 --topic first-topic
/opt/kafka/bin/kafka-console-producer.sh --bootstrap-server localhost:9092 --topic first-topic

# post a few messages and they should show up when you kill those and list topic and messages
/opt/kafka/bin/kafka-console-consumer.sh --bootstrap-server localhost:9092 --topic first-topic --from-beginning