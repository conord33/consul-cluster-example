#!/bin/bash
set -e

# Read from the file we created
SERVER_COUNT=$(cat /tmp/consul-server-count | tr -d '\n')

# Write the flags to a temporary file
cat >/tmp/consul_flags << EOF
export CONSUL_FLAGS="-server -bootstrap-expect=$SERVER_COUNT"
EOF

# Write it to the full service file
sudo mv /tmp/consul_flags /etc/service/consul
sudo chown root:root /etc/service/consul
sudo chmod 0644 /etc/service/consul

# Setup the bind address for web ui
cat >/tmp/consul-bind << EOF
{"addresses": {"http": "0.0.0.0"}}
EOF

sudo mv /tmp/consul-bind /etc/consul.d/bind.json
sudo chmod 0644 /etc/consul.d/bind.json
