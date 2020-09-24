#!/usr/bin/env bash

source /home/stack/stackrc

mkdir -p /home/stack/nodes

for node in $(openstack baremetal node list -f value -c Name); do 
  echo $node
  openstack baremetal introspection data save $node | python3 -mjson.tool > /home/stack/nodes/overcloud-$node;
done
