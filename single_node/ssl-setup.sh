#!/bin/bash
# now configure zookeeper 
sudo mkdir /opt/kafka/ssl
cd /opt/kafka/ssl

# generate a key and cert used for all operations thereafter
openssl req -new -x509 -keyout ca-key -out ca-cert -days 365 #prhase is 123465, 

# zookeeper
keytool -keystore kafka.zookeeper.truststore.jks -alias ca-cert -import -file ca-cert #password
keytool -keystore kafka.zookeeper.keystore.jks -alias zookeeper -validity 365 -genkey -keyalg RSA -ext SAN=dns:localhost #passphrase # might be problem here as common name was set not to localhost!
keytool -keystore kafka.zookeeper.keystore.jks -alias zookeeper -certreq -file ca-request-zookeeper
openssl x509 -req -CA ca-cert -CAkey ca-key -in ca-request-zookeeper -out ca-signed-zookeeper -days 365 -CAcreateserial #123456
keytool -keystore kafka.zookeeper.keystore.jks -alias ca-cert -import -file ca-cert #passphrase
keytool -keystore kafka.zookeeper.keystore.jks -alias zookeeper -import -file ca-signed-zookeeper # passphrase

# remove stuff you don't need
rm ca-signed-zookeeper ca-request-zookeeper ca-cert.srl 

# then add the additional zk_ssl.properties to your zookeeper.properties
# restart the zookeeper service and look into either server.log. You should see:
[2022-10-31 18:29:55,287] INFO binding to port 0.0.0.0/0.0.0.0:2182 (org.apache.zookeeper.server.NettyServerCnxnFactory)
[2022-10-31 18:29:55,292] INFO bound to port 2182 (org.apache.zookeeper.server.NettyServerCnxnFactory)


# for your broker (repeat for each one)
keytool -keystore kafka.broker0.truststore.jks -alias ca-cert -import -file ca-cert
keytool -keystore kafka.broker0.keystore.jks -alias broker0 -validity 365 -genkey -keyalg RSA -ext SAN=dns:localhost
keytool -keystore kafka.broker0.keystore.jks -alias broker0 -certreq -file ca-request-broker0
openssl x509 -req -CA ca-cert -CAkey ca-key -in ca-request-broker0 -out ca-signed-broker0 -days 365 -CAcreateserial
keytool -keystore kafka.broker0.keystore.jks -alias ca-cert -import -file ca-cert 
keytool -keystore kafka.broker0.keystore.jks -alias broker0 -import -file ca-signed-broker0

# for producer
keytool -keystore kafka.producer.truststore.jks -alias ca-cert -import -file ca-cert
keytool -keystore kafka.producer.keystore.jks -alias producer -validity 365 -genkey -keyalg RSA -ext SAN=dns:localhost
keytool -keystore kafka.producer.keystore.jks -alias producer -certreq -file ca-request-producer
openssl x509 -req -CA ca-cert -CAkey ca-key -in ca-request-producer -out ca-signed-producer -days 365 -CAcreateserial
keytool -keystore kafka.producer.keystore.jks -alias ca-cert -import -file ca-cert 
keytool -keystore kafka.producer.keystore.jks -alias producer -import -file ca-signed-producer

# for consumer
keytool -keystore kafka.consumer.truststore.jks -alias ca-cert -import -file ca-cert
keytool -keystore kafka.consumer.keystore.jks -alias consumer -validity 365 -genkey -keyalg RSA -ext SAN=dns:localhost
keytool -keystore kafka.consumer.keystore.jks -alias consumer -certreq -file ca-request-consumer
openssl x509 -req -CA ca-cert -CAkey ca-key -in ca-request-consumer -out ca-signed-consumer -days 365 -CAcreateserial
keytool -keystore kafka.consumer.keystore.jks -alias ca-cert -import -file ca-cert 
keytool -keystore kafka.consumer.keystore.jks -alias consumer -import -file ca-signed-consumer