#!/bin/bash
#
# Sample commands to set up Rosetta and integrate with AWS big data solutions.
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

# sample data record
# {"host":"104.129.146.40","user":null,"method":"GET","path":"/item/finance/806","code":200,"size":119,"referer":"/search/?c=Cameras+Health","agent":"Mozilla/5.0 (compatible; MSIE 9.0; Windows NT 6.1; Trident/5.0)","@node":"ip-172-31-11-77","@timestamp":"2013-11-06T09:08:51.000Z","@version":"1","type":"apache_access","tags":["apache_access"],"geoip":{"country_code2":"US"}}


#### Kibana ####
# simple query: games
# advanced query: (games OR books) AND size:[130 TO 200]


#### HIVE ####
# login
ssh hadoop@xxxx.compute.amazonaws.com

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

# nested json_tuple
select concat(b.timestamp, ',', b.code, ',', b.path, ',', c.country_code2)
from apache_logs a
LATERAL VIEW json_tuple(a.log, '@timestamp', 'code', 'path', 'geoip') b
as timestamp, code, path, geoip
LATERAL VIEW json_tuple(b.geoip, 'country_code2') c
as country_code2
limit 1;

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
psql -d mydb -h xxxx.redshift.amazonaws.com -p 5439 -U your_user -W

create table apache_logs (timestamp char(24), code int, path varchar);

# copy apache_logs from 's3://rosetta-logs/csv' into RedShift
copy apache_logs from 's3://rosetta-logs/csv/000'
credentials 'aws_access_key_id=<YOUR_KEY>;aws_secret_access_key=<SECRET_KEY>'
delimiter ',';

# a simple RedShift query
select * from apache_logs where code != 200;


#### s3distcp ####
# Combine all the log files written in one day into a single file,
# compressed using LZO codec,
# target file sets to 1.5GB
./elastic-mapreduce --jobflow j-T1ACLO7Y39R2 --jar \
/home/hadoop/lib/emr-s3distcp-1.0.jar \
--arg --src --arg 's3://rosetta-logs/apache/' \
--arg --dest --arg 's3://rosetta-logs/archive/' \
--arg --outputCodec --arg 'lzo' \
--arg --groupBy --arg '.*\.ip-.*\.([0-9]+-[0-9]+-[0-9]+)T.*\.txt' \
--arg --targetSize --arg 12288


#### HBase ####

# (FULL) convert to tsv, save in S3
INSERT OVERWRITE DIRECTORY 's3://rosetta-logs/tsv'
select concat(b.path, '|', b.timestamp, '\t', b.host, '\t',  b.method, '\t', b.code, '\t', b.size, '\t', b.referer, '\t', b.agent, '\t', b.node, '\t', c.country_code2)
from apache_logs a
LATERAL VIEW json_tuple(a.log, 'host', 'user', 'method', 'path', 'code', 'size', 'referer', 'agent', '@node', '@timestamp', 'geoip') b
as host, user, method, path, code, size, referer, agent, node, timestamp, geoip
LATERAL VIEW json_tuple(b.geoip, 'country_code2') c
as country_code2;

# create a hive table to load the tsv file
CREATE EXTERNAL TABLE hive_apache_logs (
  key STRING,
  host STRING,
  method STRING,
  code SMALLINT,
  size INT,
  referer STRING,
  agent STRING,
  node STRING,
  cc2 STRING
)
ROW FORMAT DELIMITED FIELDS TERMINATED BY '\t' STORED AS TEXTFILE
LOCATION  's3://rosetta-logs/tsv';


# create a hive-managed hbase table
CREATE TABLE hbase_apache_logs (
  key STRING,
  host STRING,
  method STRING,
  code SMALLINT,
  size INT,
  referer STRING,
  agent STRING,
  node STRING,
  cc2 STRING
)
STORED BY 'org.apache.hadoop.hive.hbase.HBaseStorageHandler'
WITH SERDEPROPERTIES ('hbase.columns.mapping' = ':key,a:host,a:method,a:code,a:size,a:referer,a:agent,a:node,a:cc2')
TBLPROPERTIES ('hbase.table.name' = 'apache_logs');

# insert data into hbase table
INSERT OVERWRITE TABLE hbase_apache_logs SELECT * FROM hive_apache_logs where key is not null;

# alter table
disable 'apache_logs'
alter 'apache_logs', {NAME => 'a', DATA_BLOCK_ENCODING => 'NONE', BLOOMFILTER => 'ROW', REPLICATION_SCOPE => '0', VERSIONS => '3', COMPRESSION => 'NONE', MIN_VERSIONS => '0', TTL => '2147483647', KEEP_DELETED_CELLS => 'false', BLOCKSIZE => '65536', IN_MEMORY => 'false', ENCODE_ON_DISK => 'true', BLOCKCACHE => 'true'}
enable 'apache_logs'

# schedule backup
./elastic-mapreduce -j j-10Y9155ATLNDP --jar /home/hadoop/lib/hbase.jar emr.hbase.backup.Main, --set-scheduled-backup, true, --backup-dir, s3://rosetta-logs/hbase, --incremental-backup-time-interval, 24, --incremental-backup-time-unit, hours, --start-time, now, --consistent

