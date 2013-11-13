Rosetta
=======

Log Management Makes Easy
-------------------------
Rosetta makes log management easier by automating the setup of several open source log management software.

Features including:

* Real-time log collection.
* Log search.
* Dashboard.
* Sending logs to Amazon S3.
* Automate all the setup.

Demo site
---------

To demo the basic auth feature, the demo site is protected by password. The user/password is `rosetta/rosettademo` (configured in _rosetta/chef/attributes/aws.yml_).

* [Demo Dashboard](http://ec2-54-200-177-9.us-west-2.compute.amazonaws.com/index.html#/dashboard/elasticsearch/uprush::default)
* [Default Dashboard](http://ec2-54-200-177-9.us-west-2.compute.amazonaws.com/index.html#/dashboard/file/logstash.json)

Logs are also stored in S3
--------------------------

Data is stored in JSON format, which is easy to parse and add new fields in the logs.

    {"host":"104.24.56.37","user":null,"method":"GET","path":"/item/jewelry/113","code":200,"size":138,"referer":null,"agent":"Mozilla/5.0 (compatible; MSIE 9.0; Windows NT 6.1; Trident/5.0)","@node":"ip-172-31-11-76","@timestamp":"2013-11-13T04:01:17.000Z","@version":"1","type":"apache_access","tags":["apache_access"]}

Use Hive to query JSON logs.

    CREATE  EXTERNAL  TABLE apache_logs
    (
      log STRING
    )
    ROW FORMAT DELIMITED FIELDS TERMINATED BY '\t' STORED AS TEXTFILE
    LOCATION  's3://rosetta-logs/apache';


    select b.*
    from apache_logs a
    LATERAL VIEW json_tuple(a.log, '@timestamp', 'code', 'path') b
    as timestamp, code, path
    where b.code != 200
    limit 100;

Find more Hive and RedShift query samples in _rosetta/aws/commands.sh_.

Pre-requisites
--------------
* Ubuntu 13.04 raring

Architecture
------------

There are four components:

* __Rosetta Agent__: A Fluentd daemon running on the server where logs are generated.
* __Rosetta Broker__: Redis server acts as a FIFO queue. Logs collected by agents are sent to broker.
* __Rosetta Filter__: LogStash server to consume input from broker, perform filtering and data manipulation on each input entry, output result to multiple targets.
* __Rosetta Indexer__: ElasticSearch cluster to index logs.
* __Rosetta Dashboard__: Kibana as the front-end of the ElasticSearch cluster. Provide search interface and customize dashboard.

![Rosetta Architecture](https://s3-us-west-2.amazonaws.com/yifeng-public/images/rosetta-architecture.png)

Setup
-----

Deployment is automated using Chef-solo and Capistrano. Setup should be able to complete by several commands.

The first step is to bootstrap a Rosetta operation center.

	curl https://raw.github.com/uprush/rosetta/master/bootstrap.sh | bash

All operations are defined as Capistrano tasks. The tasks are expected to execute on the operation center.

Execute following steps on the operation center to set up Rosetta components:

1. Export Rosetta global environment variables, including ROSETTA_ENV and ROSETTA_ZONE.
2. Change your configuration in _rosetta/chef/attributes/<ROSETTA_ENV>.yml_.
3. Configure server IPs of eash the componens in _rosetta/config/<ROSETTA_ENV>-<ROSETTA_ZONE>.rb_.
4. Distribute Chef cookbooks to target servers.
5. Set up the component.

A sample setup flow as follows:

    # 1. Export environment variables
    export ROSETTA_ENV=aws
    export ROSETTA_ZONE=a

    # 2. Change environment attributes
    vi rosetta/chef/attributes/aws.yml

    # 3. Change zone specific configurations like component server IPs
    vi rosetta/config/aws-a.rb

    # 4. Distribute Chef cookbooks to rosetta agents
    cd rosetta
    TARGET=agent cap rosetta:common:dist_cookbook

    # 5. set up rosetta agents
    cap rosetta:agent:setup

See a list of Capistrano tasks:

	cd ~/rosetta && cap -T
