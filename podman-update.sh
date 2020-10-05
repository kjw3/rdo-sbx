#!/usr/bin/env bash

sudo sed -i s/^SELINUX=.*$/SELINUX=enforcing/ /etc/selinux/config
sudo setenforce 1
sudo dnf module disable -y container-tools:rhel8
sudo dnf module enable -y container-tools:2.0
sudo dnf upgrade -y podman
sudo systemctl disable --now tripleo_nova_libvirt
sudo podman rm nova_libvirt
sudo paunch apply --file /var/lib/tripleo-config/container-startup-config/step_3/nova_libvirt.json --config-id step_3
sudo systemctl enable tripleo_nova_libvirt
