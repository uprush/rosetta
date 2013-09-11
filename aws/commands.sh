#!/bin/bash
#
# Crate AMIs.
# How to create AMIs for Rosetta?
# - Launch an EC2 instance with Ubuntu Raring
# - Install Ruby and Chef on the instance (via rosetta/bootstrap.sh)
# - Add necessary public keys (e.g. your keys on operation center) to /home/ubuntu/.ssh/authorized_keys
# - Create a snapshot for the root volume of the instance.
# - Create AMI from the snapshot.
#

# create a snapshot from Rosetta operation center
aws ec2 create-snapshot --volume-id vol-63f5610a

# register AMI with snapshot
aws ec2 register-image \
  --dry-run \
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
