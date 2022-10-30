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


## Configuration Kafka to use SSL

Now lets add ssl requirements. Basic steps:

1. Generate the keys and certificates
2. Create your own Certificate Authority (CA)
3. Sign the certificate

We will configure in 4 sections: Zookeeper broker(s), Zookeeper client, 

# Zookeeper broker

The following commands will work but note you will have to input information yourself so they won't just run. 

```
mkdir /opt/kafka/ssl
cd /opt/kafka/ssl

keytool -keystore server.keystore.jks -alias localhost -validity 365 -genkey -keyalg RSA -ext SAN=DNS:localhost
keytool -list -v -keystore server.keystore.jks
keytool -keystore kafka.server.keystore.jks -alias localhost -keyalg RSA -validity 365 -genkey -storepass storekey -keypass storekey -dname "CN=Dean Flanagan, OU=Cloud, O=Sky Solutions, L=Fredericton, ST=NB, C=CA" -ext SAN=DNS:localhost

openssl req -new -x509 -keyout ca-key -out ca-cert -days 365
keytool -keystore kafka.client.truststore.jks -alias CARoot -importcert -file ca-cert
keytool -keystore kafka.server.truststore.jks -alias CARoot -importcert -file ca-cert

keytool -keystore kafka.server.keystore.jks -alias localhost -certreq -file cert-file
keytool -keystore kafka.server.keystore.jks -alias CARoot -importcert -file ca-cert
keytool -keystore kafka.server.keystore.jks -alias localhost -importcert -file cert-signed
```
Now add this to your zookeeper.properties (note I used passwords as 123456 so change to your own):

```
clientPort=2181
secureClientPort=2182
authProvider.x509=org.apache.zookeeper.server.auth.X509AuthenticationProvider
serverCnxnFactory=org.apache.zookeeper.server.NettyServerCnxnFactory
ssl.trustStore.location=/opt/kafka/ssl/kafka.zookeeper.truststore.jks
ssl.trustStore.password=123456
ssl.keyStore.location=/opt/kafka/ssl/kafka.zookeeper.keystore.jks
ssl.keyStore.password=123456
ssl.clientAuth=need
```

Restart your zookeeper:

```
sudo systemctl restart zookeeper
```

Now check out your logs in either logs/server.log or zookeeper-gc.log to see the new configuration. It should be running on port 2182.



# Zookeeper client

cd /opt/kafka/config
sudo touch zookeeper-client.properties

keytool -keystore kafka.zookeeper-client.truststore.jks -alias ca-cert -import -file ca-cert
keytool -keystore kafka.zookeeper-client.keystore.jks -alias zookeeper-client -validity 360 -genkey -keyalg RSA -ext SAN=dns:localhost
keytool -keystore kafka.zookeeper-client.keystore.jks -alias zookeeper-client -certreq -file ca-request-zookeeper-client
openssl x509 -req -CA ca-cert -CAkey ca-key -in ca-request-zookeeper-client -out ca-signed-zookeeper-client -days 365 -CArecreateserial 
keytool -keystore kafka.zookeeper-client.keystore.jks -alias ca-cert -import -file ca-cert
keytool -keystore kafka.zookeeper-client.keystore.jks -alias zookeeper-client -import -file ca-signed-zookeeper-client