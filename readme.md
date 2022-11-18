# Kafka Basic Commands

This document outlines how use Apache Kafka in a single node and some basic troubleshooting steps for a production (cluster) setup.

**Table of Contents**

1. [Introduction](#introduction)
2. [How it works](#install)
3. [Troubleshooting](#troubleshooting)

## Introduction <a name="introduction"></a>

Apache Kafka is a distributed logging/messaging technology. It's used to distribute and replicate (copy) messages that need to be retained for a certain amount of time, and allows services to produce to and consume from its cluster. 

A cluster of Kafka nodes is a collection of instances that have Kafka installed on them and are allowed to communicate with one another in their provisioned network. For example, in AWS one can use:

 - Terraform to provision instances, security groups, EBS storage devices
 - Ansible to provide configuration for a Kafka role and Kafka (server, consumer, producer property files), SSL and more
 - IAM roles for NewRelic or other monitoring/management tools like CMAK/Kafka Manager to administer their clusters and report on crucial metrics

 In this short tutorial I will walk through the very basics of setting up a single node (so no replicatoin) to demo how it works.

## How it works <a name="install"></a>

For this demo, I recommend setting up an AWS EC2 instance of type t2.medium. This is not free-tier eligible but using a smaller instance requires configuring Java runtime limits that aren't worth the effort for a quick demo. 

Once launched, `ssh` into your instance - which we'll call a node or broker forthwith. The execute the commands found in `single_node/localInstallation.sh`. What this does is:

1. Install the binaries needed to run Java
2. Install Kafka in a dir where you'll run your commands from
3. Set up Zookeeper and Kafka as services, enable and start them
4. Produce to a topic and consume from it

There are many other subjects on Kafka that bear mentioning. 

### Configuration and Management

Many large companies will have Kafka clusters with anywhere from 3 - 9+ nodes. The minimum recommended is 3. Say if you have 2 and 1 goes down, you don't have any replication: if that node goes down, you're in for a bad time. 

Then you have to decide on how many partitions you want per topic, and what the replication factor should be per topic. A few general rules:

- If cluster size is small - <= 5 - you should go with a replication factor of 3. For a larger number of nodes, you can use 2
- For partition count, more is mostly better. If say you have a small cluster and partition count of 15, you may get I/O throttling on the nodes themselves. Not a problem for bigger nodes/larger cluster. You may want to multiply your number of brokers by a set amount, say 2x partitions per broker. For topics you know will need scaling, you might want a higher number to account for a future increase in consumer groups off that topic. 

### Server Properties

For large systems that manage their own clusters (as opposed to Confluence or other companies that outsource cluster management), server, producer and consumer properties are absolutely worth exploring. This is a very deep topic and Confluence have a great guide on it that I won't get into here. But the crux is how to decide on behaviour for your cluster by determing whats important:

- Latency
- Durability
- Throughput
- Availability

An organization might be best served by setting up multiple clusters for each business need, configuring as necessary.

### Encryption

A brief `ssl-setup.sh` file has been included in this folder. In brief, there may be a regulatory need to encrypt data flowing through Kafka. The script provided should give an idea how you would approach setting it up through use of `openssl` and `keytool`. 

### Zookeeper

Finally, the most recent versions of Kafka have done away with Zookeeper. Used to manage the distribution of messages and organize your configuration. Personally, it was a pain to have to provision separate nodes for ZK and the omission is welcome.

## Troubleshooting <a name="troubleshooting"></a>

When self managing your cluster, typical issues that arise might be:

- Nodes/brokers becoming unavailable
- Bad messages blocking consumer groups
- Services not starting due to IAC errors/misses

The commands in included below indicate how one might begin to troubleshoot these issues. 

```
# check if service is enabled
systemctl is-enabled kafka.service

# check if service is active
systemctl is-active kafka.service

# check if any under-replicated partitions on zookeeper or kakfa node
/opt/kafka/bin/kafka-topics.sh --zookeeper $(hostname -s):2181 --describe --under-replicated-partitions | wc -l
/opt/kafka/bin/kafka-topics.sh --bootstrap-server $(hostname -s):9092 --describe --under-replicated-partitions | wc -l

# if a high lag is reported for any consumer group, first find your consumer group from this list. Note the egrep that filters out UUIDs, which are assigned to a consuerm group if the group wasn't given a name
/opt/kafka/bin/kafka-consumer-groups.sh --list --bootstrap-server $(hostname -s):9092 | egrep  -v '[0-9a-f]{8}-([0-9a-f]{4}-){3}[0-9a-f]{8}'

# then describe to see the lag
/opt/kafka/bin/kafka-consumer-groups.sh --describe --bootstrap-server $(hostname -s):9092 --group ucm-messages

# now say your lag is high on a certain partition. You will first want to see if it's stuck or progressing. You can do
watch   /opt/kafka/bin/kafka-consumer-groups.sh --describe --bootstrap-server $(hostname -s):9092 --group ucm-messages

# take a screenshot and see if the lag is not moving on a certain partition. The problem is usually a bad message. So we can skip the message and change the offset in a number of ways
# this command will skip one message on partition zero 
kafka-consumer-groups.sh --bootstrap-server kafka-host:9092 --group my-group --reset-offsets --shift-by 1 --topic sales_topic:0 --execute
```