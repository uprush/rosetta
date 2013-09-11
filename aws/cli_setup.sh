#!/bin/bash
#
# Boot the operation center on AWS.
#

# install pip
sudo apt-get install -y python-pip

# install AWS CLI
sudo pip install awscli

mkdir -p ~/.aws
chmod 700 ~/.aws

cat <<-EOH > ~/.aws/config
[default]
aws_access_key_id = <YOUR_KEY>
aws_secret_access_key = <YOUR_SECRET_KEY>
region = <DEFAULT_REGION>
EOH

chmod 700 ~/.aws/config

echo 
echo "DONE"
echo "Do NOT forget to change your AWS key in ~/.aws/config"
echo "After that run 'aws ec2 describe-instances' to confirm AWS CLI setup."
echo

