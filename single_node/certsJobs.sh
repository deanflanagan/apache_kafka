#!/bin/bash

# Steps:

# Generate the keys and certificates
# Create your own Certificate Authority (CA)
# Sign the certificate

# Items:

# keystore: the location of the keystore
# ca-cert: the certificate of the CA
# ca-key: the private key of the CA
# ca-password: the passphrase of the CA
# cert-file: the exported, unsigned certificate of the server
# cert-signed: the signed certificate of the server

keytool -keystore server.keystore.jks -alias localhost -validity 365 -genkey -keyalg RSA -ext SAN=DNS:localhost
keytool -list -v -keystore server.keystore.jks

keytool -keystore kafka.server.keystore.jks -alias localhost -keyalg RSA -validity 365 -genkey -storepass storekey -keypass storekey -dname "CN=Dean Flanagan, OU=Cloud, O=Sky Solutions, L=Fredericton, ST=NB, C=CA" -ext SAN=DNS:localhost

openssl req -new -x509 -keyout ca-key -out ca-cert -days 365
keytool -keystore kafka.client.truststore.jks -alias CARoot -importcert -file ca-cert
keytool -keystore kafka.server.truststore.jks -alias CARoot -importcert -file ca-cert

keytool -keystore kafka.server.keystore.jks -alias localhost -certreq -file cert-file
keytool -keystore kafka.server.keystore.jks -alias CARoot -importcert -file ca-cert
keytool -keystore kafka.server.keystore.jks -alias localhost -importcert -file cert-signed
