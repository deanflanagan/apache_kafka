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

# then edit your kafka and zookeeper server start files to use less memory:
sudo nano /opt/kafka/bin/zookeeper-server-start.sh 

# change KAFKA_HEAD_OPTS to
export KAFKA_HEAP_OPTS="-Xms32M -Xmx64M"


sudo nano /opt/kafka/bin/kafka-server-start.sh 
export KAFKA_HEAP_OPTS="-Xms32M -Xmx64M"

# exit the ssh connection and re-enter. Then run
sudo systemctl restart zookeeper
sudo systemctl restart kafka 

# now open another shell and lets see if its all working
