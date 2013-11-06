#!/bin/bash
#
# How to set up Rosetta on AWS?
# - Launch an EC2 instance with Ubuntu Raring
# - Install Ruby and Chef on the instance (via rosetta/bootstrap.sh)
# - Add necessary public keys (e.g. your keys on operation center) to /home/ubuntu/.ssh/authorized_keys
# - Create a snapshot for the root volume of the instance.
# - Create AMI from the snapshot.
# - Launch EC2 instances using created AMI.
# - Configure Rosetta component hosts in `config/aws-x.rb`
# - Set up Rosetta components using capistrano and chef on operation center.
#

# create a snapshot from Rosetta operation center
aws ec2 create-snapshot --volume-id vol-63f5610a

# register AMI with snapshot
aws ec2 register-image \
  --name 'ubuntu-raring64-rosetta-base' \
  --description 'raring with ruby2.0.0-p247 and chef 11.6.0' \
  --architecture x86_64 \
  --root-device-name /dev/sda1 \
  --kernel-id aki-fc37bacc \
  --block-device-mappings '[{"DeviceName": "/dev/sda1", "Ebs": {"SnapshotId": "snap-1642162b", "VolumeSize": 8}}, {"VirtualName": "ephemeral0", "DeviceName": "/dev/sdb"}]'

# Launch EC2 instance
aws ec2 run-instances \
  --image-id ami-723ea242 \
  --count 1 \
  --instance-type t1.micro \
  --key-name ubuntu@jump1 \
  --subnet-id subnet-d9de0eb2

# Create ElastiCache with Redis
aws elasticache create-cache-cluster

# sample data record
# {"host":"104.129.146.40","user":null,"method":"GET","path":"/item/finance/806","code":200,"size":119,"referer":"/search/?c=Cameras+Health","agent":"Mozilla/5.0 (compatible; MSIE 9.0; Windows NT 6.1; Trident/5.0)","@node":"ip-172-31-11-77","@timestamp":"2013-11-06T09:08:51.000Z","@version":"1","type":"apache_access","tags":["apache_access"]}

# create hive table
# hive>
# CREATE  EXTERNAL  TABLE apache_logs
# (
#   log STRING
# )
# ROW FORMAT DELIMITED FIELDS TERMINATED BY '\t' STORED AS TEXTFILE
# LOCATION  's3://rosetta-logs/apache';

# sample query
# hive> select count(1) from apache_logs;

