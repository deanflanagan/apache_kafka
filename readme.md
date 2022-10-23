# Kafka SSL

<img src="https://www.nicepng.com/png/detail/246-2467588_kafka-logo-tall-apache-kafka-logo.png" alt="drawing" width="200"/>

## Table of Contents
1. [Objective](#Objective)
2. [Local Setup on single node](#Local_Setup)
3. [Configuration](#Configuration)
4. [Testing](#Testing<space>Locally)


## Objective

By default, Apache Kafka® communicates in <abbr>PLAINTEXT</abbr>, which means that all data is sent in the clear. To encrypt communication, you should configure all the Kafka to use <abbr>SSL</abbr> encryption.

This quick guide show the configuration setup to set configuration settings to enforce SSL. Initially I will have a script for a local installation of Kafka to be installed. Then i'll show how to set up a full Terraform & Ansible cluster provisioned with full internode communication.

## Local_Setup

The script below shows how to install and set up Kafka for a single node. This is solely to enlighten how SSL communication will work (no internode yet) will minimal configuration. Use the files in the single_node directory to run the script below yourself.

```
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

```

Now a quick test in two shells with a consumer and producer so we can see messages come through with plaintext.

```
# a quick creation of a topic and then list that topics messages
/opt/kafka/bin/kafka-topics.sh --create --topic first-topic --bootstrap-server localhost:9092

# open a new terminal and write to thate topic in a consumer. Open a console consumer in the first terminal
/opt/kafka/bin/kafka-console-consumer.sh --bootstrap-server localhost:9092 --topic first-topic
/opt/kafka/bin/kafka-console-producer.sh --bootstrap-server localhost:9092 --topic first-topic

# post a few messages and they should show up when you kill those and list topic and messages
/opt/kafka/bin/kafka-console-consumer.sh --bootstrap-server localhost:9092 --topic first-topic --from-beginning
```

So now we'll change the server.properties to use a new port and SSL encryption. The first step is to create our truststore and keystore. Once created, and commands will have to use the right port and include the key within any command to get a result. 

## Configuration

So, optimization considerations aside, the vanilla Kafka installation will allow for quick and dirty testing for topic creation and population. Some quick data to be input: 

`enter data injection here`

## Testing<space>Locally

[mailto:test.test@gmail.com](mailto:test.test@gmail.com)
