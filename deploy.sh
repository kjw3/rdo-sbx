#!/usr/bin/env bash

source ~/stackrc

time openstack overcloud deploy --templates \
  -r /home/stack/templates/roles_data.yaml \
  -n /home/stack/templates/network_data.yaml \
  -e /home/stack/templates/containers-prepare-parameter.yaml \
  -e /usr/share/openstack-tripleo-heat-templates/environments/podman.yaml \
  -e /home/stack/templates/podman-ha.yaml \
  -e /usr/share/openstack-tripleo-heat-templates/environments/enable-swap.yaml \
  -e /usr/share/openstack-tripleo-heat-templates/environments/disable-telemetry.yaml \
  -e /home/stack/templates/node-info.yaml \
  -e /home/stack/templates/inject-trust-anchor-hiera.yaml \
  -e /usr/share/openstack-tripleo-heat-templates/environments/services/octavia.yaml \
  -e /usr/share/openstack-tripleo-heat-templates/environments/ceph-ansible/ceph-ansible.yaml \
  -e /usr/share/openstack-tripleo-heat-templates/environments/ceph-ansible/ceph-rgw.yaml \
  -e /usr/share/openstack-tripleo-heat-templates/environments/ceph-ansible/ceph-dashboard.yaml \
  -e /usr/share/openstack-tripleo-heat-templates/environments/cinder-backup.yaml \
  -e /home/stack/templates/ceph-environment.yaml \
  -e /usr/share/openstack-tripleo-heat-templates/environments/services/neutron-ovn-dvr-ha.yaml \
  -e /home/stack/templates/network-isolation.yaml \
  -e /home/stack/templates/network-environment.yaml \
  -e /home/stack/templates/firstboot-environment.yaml
