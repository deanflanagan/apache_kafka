#!/bin/bash

sudo apt-get update
# install java
sudo apt install default-jre

# export default java to environment
echo "JAVA_HOME=/usr/bin/java" | sudo tee -a /etc/environment

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

# testing phase. First lets allow all of the 4lw commands for testing
echo "4lw.commands.whitelist=*" | sudo tee -a /opt/kafka/config/zookeeper.properties 

# reload zookeeper service
sudo systemctl restart zookeeper

# lets download a UI to make life easier
gh repo clone yahoo/CMAK

# make a build
./CMAK/sbt clean dist

# one of the last lines will show Your package is ready in /home/dean/Desktop/coding/kakfa_ssl/CMAK/target/universal/cmak-3.0.0.6.zip. Unzip it

