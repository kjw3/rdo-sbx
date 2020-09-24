#!/usr/bin/bash

#Parameters
user=operator
password=p@ssw0rd
email=operator@kdjlab.com
tenant=operators
externalNetwork=public
externalCidr='192.168.100.0/24'
externalVlanId=2100
externalGateway=192.168.100.1
externalDns=10.99.99.12
externalFipStart=192.168.100.100
externalFipEnd=192.168.100.149
tenantNetwork=private
tenantCidr='172.16.100.0/24'
keypairName=stack
keypairPubkey="ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAAAgQC5TLIRtPzzUlHlQJU2Myq9hGrV9sSgfTjvNxjm2nhPffIH/ZGngbsGKnzrGS+wwDd27SWOa3jntD4SqYqQsyVyT54O1vTPg0YMC6DmyF+4KyWc970Vj8uOlKBOzOKc3AxS4gSlzcBNCt6YZI+R1d0dbfjPl0X6QCDeZ1c2IdooFw=="

unset OS_PROJECT_NAME
unset OS_TENANT_NAME

#Start as the admin user
source /home/stack/overcloudrc

#Create the operators tenant and operator user defined above
openstack project create $tenant --description "Project intended for shared resources and testing by Operators" --enable
openstack quota set --ram 262144 --instances 20 --cores 80 --gigabytes 1000 --volumes 40 $tenant
openstack user create $user --project $tenant --password $password --email $email --enable

#Grant the admin role to the operator admin
openstack role add admin --user $user --project $tenant

#create an rc file for the new operator user
cp /home/stack/overcloudrc /home/stack/${user}rc
sed -i "s/\(OS_USERNAME=\).*/\1${user}/" /home/stack/${user}rc
sed -i "s/\(OS_TENANT_NAME=\).*/\1${tenant}/" /home/stack/${user}rc
sed -i "s/\(OS_PROJECT_NAME=\).*/\1${tenant}/" /home/stack/${user}rc
sed -i "s/\(OS_PASSWORD=\).*/\1${password}/" /home/stack/${user}rc

#Switch to the new operator
source /home/stack/${user}rc

#Add ICMP and SSH incoming rules to the default security group in operators tenant
openstack security group rule create --protocol icmp $(openstack security group list --project operators -c ID -f value)
openstack security group rule create --protocol tcp $(openstack security group list --project operators -c ID -f value)
openstack security group rule create --protocol udp $(openstack security group list --project operators -c ID -f value)

#Create a temp public key file
echo $keypairPubkey > /tmp/${keypairName}.pub
#Import the public key for the operator user
openstack keypair create --public-key /tmp/${keypairName}.pub $keypairName

#Create a base flavor for use later
openstack flavor create --id 1 --ram 256 --disk 1 --vcpus 1 --public m1.tiny
openstack flavor create --id 2 --ram 2048 --disk 10 --vcpus 1 --public m1.small
openstack flavor create --id 3 --ram 4096 --disk 20 --vcpus 2 --public m1.medium
openstack flavor create --id 4 --ram 8192 --disk 40 --vcpus 4 --public m1.large
openstack flavor create --id 5 --ram 16384 --disk 80 --vcpus 8 --public m1.xlarge

#Create shared external network

#External is VLAN
openstack network create --provider-network-type vlan --provider-physical-network datacentre --provider-segment $externalVlanId --share --external $externalNetwork

#External is Flat
#openstack network create --provider-network-type flat --provider-physical-network datacentre --external $externalNetwork

#Create external subnet
neutron subnet-create $externalNetwork $externalCidr --name ${externalNetwork}-sub --disable-dhcp --allocation-pool=start=$externalFipStart,end=$externalFipEnd --gateway=$externalGateway --dns-nameserver $externalDns

#Create a private tenant vxlan network
openstack network create $tenantNetwork

#Create private tenant subnet
neutron subnet-create $tenantNetwork $tenantCidr --name ${tenantNetwork}-sub --dns-nameserver $externalDns

#Create a router
neutron router-create router-$externalNetwork
#Add an interface on the router for the tenant network
neutron router-interface-add router-$externalNetwork ${tenantNetwork}-sub
#Set the external gateway on the new router
neutron router-gateway-set router-$externalNetwork $externalNetwork

mkdir -p /home/stack/overcloud_guest_images
curl http://download.cirros-cloud.net/0.5.1/cirros-0.5.1-x86_64-disk.img -o /home/stack/overcloud_guest_images/cirros-0.5.1-x86_64-disk.img
curl https://cloud.centos.org/centos/7/images/CentOS-7-x86_64-GenericCloud.qcow2 -o /home/stack/overcloud_guest_images/CentOS-7-x86_64-GenericCloud.qcow2
curl https://cloud.centos.org/centos/8/x86_64/images/CentOS-8-GenericCloud-8.2.2004-20200611.2.x86_64.qcow2 -o /home/stack/overcloud_guest_images/CentOS-8-GenericCloud-8.2.2004-20200611.2.x86_64.qcow2
curl http://mirror.siena.edu/fedora/linux/releases/32/Cloud/x86_64/images/Fedora-Cloud-Base-32-1.6.x86_64.qcow2 -o /home/stack/overcloud_guest_images/Fedora-Cloud-Base-32-1.6.x86_64.qcow2
curl https://cloud-images.ubuntu.com/releases/bionic/release/ubuntu-18.04-server-cloudimg-amd64.img -o /home/stack/overcloud_guest_images/ubuntu-18.04-server-cloudimg-amd64.img
curl https://cloud-images.ubuntu.com/releases/focal/release/ubuntu-20.04-server-cloudimg-amd64.img -o /home/stack/overcloud_guest_images/ubuntu-20.04-server-cloudimg-amd64.img

# uploading of images into glance
openstack image create --container-format bare --disk-format qcow2 --min-disk 1 --min-ram 64 --file /home/stack/overcloud_guest_images/cirros-0.5.1-x86_64-disk.img --public cirros-0.5.1
openstack image create --container-format bare --disk-format qcow2 --min-disk 10 --min-ram 2048 --file /home/stack/overcloud_guest_images/CentOS-7-x86_64-GenericCloud.qcow2 --public centos-7
openstack image create --container-format bare --disk-format qcow2 --min-disk 10 --min-ram 2048 --file /home/stack/overcloud_guest_images/CentOS-8-GenericCloud-8.2.2004-20200611.2.x86_64.qcow2 --public centos-8
openstack image create --container-format bare --disk-format qcow2 --min-disk 10 --min-ram 2048 --file /home/stack/overcloud_guest_images/Fedora-Cloud-Base-32-1.6.x86_64.qcow2 --public fedora-32
openstack image create --container-format bare --disk-format qcow2 --min-disk 10 --min-ram 2048 --file /home/stack/overcloud_guest_images/ubuntu-18.04-server-cloudimg-amd64.img --public ubuntu-18.04
openstack image create --container-format bare --disk-format qcow2 --min-disk 10 --min-ram 2048 --file /home/stack/overcloud_guest_images/ubuntu-20.04-server-cloudimg-amd64.img --public ubuntu-20.04



