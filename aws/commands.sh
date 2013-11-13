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
# {"host":"104.129.146.40","user":null,"method":"GET","path":"/item/finance/806","code":200,"size":119,"referer":"/search/?c=Cameras+Health","agent":"Mozilla/5.0 (compatible; MSIE 9.0; Windows NT 6.1; Trident/5.0)","@node":"ip-172-31-11-77","@timestamp":"2013-11-06T09:08:51.000Z","@version":"1","type":"apache_access","tags":["apache_access"],"geoip":{"country_code2":"US"}}


#### Kibana
# QUERY: games
# (games OR books) AND size:[130 TO 200]
# My Dashboard


#### HIVE ####
# login
ssh hadoop@ec2-54-201-53-129.us-west-2.compute.amazonaws.com

# create hive table
CREATE  EXTERNAL  TABLE apache_logs
(
  log STRING
)
ROW FORMAT DELIMITED FIELDS TERMINATED BY '\t' STORED AS TEXTFILE
LOCATION  's3://rosetta-logs/apache';

# sample query
select a.* from apache_logs a limit 1;

# sample query
select b.*
from apache_logs a
LATERAL VIEW json_tuple(a.log, '@timestamp', 'code', 'path') b
as timestamp, code, path
where b.code != 200
limit 100;


# convert to csv, save in S3 (to load into RedShift)
INSERT OVERWRITE DIRECTORY 's3://rosetta-logs/csv'
select concat(b.timestamp, ',', b.code, ',', b.path)
from apache_logs a
LATERAL VIEW json_tuple(a.log, '@timestamp', 'code', 'path') b
as timestamp, code, path
where b.code > 0;

# convert to csv (sample record)
head ~/services/bigdata/demo/sample.csv

#### REDSHIFT ####
psql -d mydb -h mydb.cqsxlytconbn.us-west-2.redshift.amazonaws.com -p 5439 -U awsuser -W

create table apache_logs (timestamp char(24), code int, path varchar);

# copy apache_logs from 's3://rosetta-logs/csv'
# credentials 'aws_access_key_id=<access-key-id>;aws_secret_access_key=<secret-access-key>';

copy apache_logs from 's3://rosetta-logs/csv/000'
credentials 'aws_access_key_id=<YOUR_KEY>;aws_secret_access_key=<SECRET_KEY>'
delimiter ',';

select * from apache_logs where code != 200;


# s3distcp
# ./elastic-mapreduce --jobflow j-3GY8JC4179IOJ --jar \
# /home/hadoop/lib/emr-s3distcp-1.0.jar \
# --arg --s3Endpoint --arg 's3-us-west-2.amazonaws.com' \
# --arg --src --arg 's3://rosetta-logs/apache/' \
# --arg --dest --arg 's3://rosetta-logs/archive/' \
# --arg --srcPattern --arg '*.txt'
