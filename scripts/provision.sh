#!/bin/bash

# Get the necessary utilities and install them.
apt-get update
apt-get install -y unzip

# Get the Consul Zip file and extract it.
cd /usr/local/bin
wget https://releases.hashicorp.com/consul/0.6.3/consul_0.6.3_linux_amd64.zip
unzip *.zip
rm *.zip

# Make the Consul directory.
mkdir -p /etc/consul.d
mkdir /var/consul

# Copy config file to config directory
cp /vagrant/config.json /etc/consul.d/config.json
