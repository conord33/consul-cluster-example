#!/bin/bash
set -e

echo "Getting cluster join address for client..."
ADDR_FILE=/tmp/consul-join-addr
ADDR_FILE_TMP=/tmp/consul-join-addr-tmp
CLUSTER_ADDR=$(cat $ADDR_FILE | tr -d '\n')
curl http://$CLUSTER_ADDR:8500/v1/status/leader -o $ADDR_FILE
grep -o '[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}' $ADDR_FILE > $ADDR_FILE_TMP
mv $ADDR_FILE_TMP $ADDR_FILE
