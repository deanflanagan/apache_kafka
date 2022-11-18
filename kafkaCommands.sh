#!/bin/bash

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
/opt/kafka/bin/kafka-consumer-groups.sh --describe --bootstrap-server $(hostname -s):9092 --group topic-group-name

# now say your lag is high on a certain partition. You will first want to see if it's stuck or progressing. You can do
watch   /opt/kafka/bin/kafka-consumer-groups.sh --describe --bootstrap-server $(hostname -s):9092 --group topic-group-name

# take a screenshot and see if the lag is not moving on a certain partition. The problem is usually a bad message. So we can skip the message and change the offset in a number of ways
# this command will skip one message on partition zero 
kafka-consumer-groups.sh --bootstrap-server kafka-host:9092 --group my-group --reset-offsets --shift-by 1 --topic sales_topic:0 --execute