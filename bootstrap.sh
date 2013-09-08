#!/bin/bash
#
# Boot the operation center.
#

# configure timezone and locale
echo "Asia/Tokyo" | sudo tee /etc/timezone
sudo dpkg-reconfigure --frontend noninteractive tzdata
sudo update-locale LC_ALL=en_US.UTF-8

# install dependencies
sudo apt-get update
sudo apt-get install -y \
  git-core curl zlib1g-dev build-essential libssl-dev \
  libreadline-dev libyaml-dev libsqlite3-dev sqlite3 libxml2-dev libxslt-dev

# install ruby
cd $HOME
git clone https://github.com/sstephenson/rbenv.git .rbenv
echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.bashrc
echo 'eval "$(rbenv init -)"' >> ~/.bashrc
exec $SHELL

git clone https://github.com/sstephenson/ruby-build.git ~/.rbenv/plugins/ruby-build
echo 'export PATH="$HOME/.rbenv/plugins/ruby-build/bin:$PATH"' >> ~/.bashrc
exec $SHELL

rbenv install 2.0.0-p247
rbenv global 2.0.0-p247
ruby -v

# tell rubygems not to install the documentation for each package locally
echo "gem: --no-ri --no-rdoc" > ~/.gemrc

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
git clone https://github.com:uprush/rosetta.git
