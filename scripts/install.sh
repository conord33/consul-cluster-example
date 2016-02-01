#!/bin/bash
set -e

echo "Installing dependencies..."
sudo yum update -y
sudo yum install -y unzip wget

echo "Fetching Consul..."
cd /tmp
wget https://releases.hashicorp.com/consul/0.6.3/consul_0.6.3_linux_amd64.zip -O consul.zip

echo "Installing Consul..."
unzip consul.zip >/dev/null
sudo chmod +x consul
sudo mv consul /usr/local/bin/consul
sudo mkdir -p /etc/consul.d
sudo mkdir -p /mnt/consul
sudo mkdir -p /etc/service

# Setup the join address
JOIN_ADDRS=$(cat /tmp/consul-join-addr | tr -d '\n')
cat >/tmp/consul-join << EOF
export CONSUL_JOIN="${JOIN_ADDRS}"
EOF

sudo mv /tmp/consul-join /etc/default/consul-join
sudo chmod 0644 /etc/default/consul-join

echo "Installing Upstart service..."
sudo mv /tmp/upstart.conf /etc/init/consul.conf
sudo mv /tmp/upstart-join.conf /etc/init/consul-join.conf
