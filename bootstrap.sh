#!/bin/bash
#
# Boot the operation center.
#

if [ -f /etc/debian_version ]; then
  FAMILY="DEBIAN"
elif [ -f /etc/redhat-release ]; then
  FAMILY="RHEL"
else
  grep -q "Amazon Linux" /etc/issue
  if [ $? -eq 0 ]; then
    FAMILY="RHEL"
  fi
fi

if [ "$FAMILY" == "DEBIAN" ]; then
  # configure timezone and locale
  echo "Asia/Tokyo" | sudo tee /etc/timezone
  sudo dpkg-reconfigure --frontend noninteractive tzdata
  export LC_ALL=en_US.UTF-8
  sudo update-locale LC_ALL=en_US.UTF-8

  # install dependencies
  sudo apt-get update
  sudo apt-get install -y \
    git-core curl zlib1g-dev build-essential libssl-dev \
    libreadline-dev libyaml-dev libsqlite3-dev sqlite3 libxml2-dev libxslt-dev

elif [ "$FAMILY" == "RHEL" ]; then
  # configure timezone and locale
  sudo rm -f /etc/localtime
  sudo cp -p /usr/share/zoneinfo/Japan /etc/localtime
  sudo yum update -y
  sudo yum install -y git curl openssl-devel gcc cmake
else
  echo "Unsupported platform."
  exit 1
fi

# install ruby
cd $HOME
git clone https://github.com/sstephenson/rbenv.git .rbenv
mkdir ~/.rbenv/plugins
git clone https://github.com/sstephenson/ruby-build.git ~/.rbenv/plugins/ruby-build

export PATH="$HOME/.rbenv/bin:$HOME/.rbenv/plugins/ruby-build/bin:$PATH"
eval "$(rbenv init -)"
echo 'export PATH="$HOME/.rbenv/bin:$HOME/.rbenv/plugins/ruby-build/bin:$PATH"' >> ~/.bashrc
echo 'eval "$(rbenv init -)"' >> ~/.bashrc

rbenv install 2.1.0
rbenv global 2.1.0
ruby -v

# tell rubygems not to install the documentation for each package locally
cat <<-EOH > ~/.gemrc
---
:update_sources: true
:sources:
- http://rubygems.org/
- http://gems.rubyforge.org/
:benchmark: false
:bulk_threshold: 1000
:backtrace: false
:verbose: true
gem: --no-ri --no-rdoc
EOH

gem update --system

# install capistrano and chef
gem install capistrano
gem install chef
rbenv rehash

# configure git
cat <<-EOH > ~/.gitconfig
[core]
  editor = vim
[merge]
  tool = vimdiff
[color]
  diff = auto
  status = auto
  branch = auto
[alias]
  co = checkout
  br = branch
  ci = commit
  st = status
  unstage = reset HEAD --
  last = log -1 HEAD
EOH

# clone rosetta
# git clone https://github.com/uprush/rosetta.git ~/rosetta
# cd ~/rosetta
# git submodule update --init
