#!/bin/bash

# install java
sudo apt install default-jre

# add a kafka user
sudo useradd -d /opt/kafka -s /bin/bash kafka
sudo passwd kafka

# change dir to opt where we'll install
cd /opt 

# download Kafka
wget https://dlcdn.apache.org/kafka/3.2.0/kafka_2.13-3.2.0.tgz 

sudo mkdir -p /opt/kafka

# extract compressed kafka and move directory to usr/local
tar xzf kafka_2.13-3.2.0.tgz -C /opt/kafka --strip-components=1
sudo chown -R kafka:kafka /opt/kafka

# separate dir for logs
sudo mkdir /opt/kafka-logs
sudo chown -R kafka:kafka /opt/kafka-logs

# configure kafka and zookeeper as services
exit
cd /lib/systemd/system/
sudo nano zookeeper.service

# paste in zookeeper.service config

# now open and paste in kafka service
sudo nano kafka.service

# now reload the systemctl manager and enable and start both services

sudo systemctl daemon-reload 

sudo systemctl start zookeeper
sudo systemctl enable zookeeper

sudo systemctl start kafka
sudo systemctl enable kafka

# testing phase
# logging in as the kafka user

su - kafka 