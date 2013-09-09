#!/bin/bash
#
# Boot the operation center on AWS.
#

# install pip
sudo apt-get install python-pip

# install AWS CLI
sudo pip install awscli

aws ec2 describe-instances

mkdir ~/.aws
chmod 700 ~/.aws

cat <<-EOH > ~/aws/config
[default]
aws_access_key_id = <YOUR_KEY>
aws_secret_access_key = <YOUR_SECRET_KEY>
region = us_west_2
EOH

chmod 700 ~/.aws/config
