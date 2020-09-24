# rdo-sbx
## RDO Deployment for Shadowbox

The files in the repository go along with several articles that I wrote on deploying [RDO](https://www.rdoproject.org/) into my home lab. The point of the example repo and the articles is to try and show an order of operations and use of official documentation to create a stable, production representative deployment of [OpenStack](https://www.openstack.org/) using [TripleO](https://docs.openstack.org/tripleo-docs/latest/).

This deployment will apply to both RDO and Red Hat OpenStack Platform (RHOSP). The articles walk through a deployment using the OpenStack Train release. This release maps to RHOSP 16. There are minor differences between RDO and RHOSP deployments. If you are planning to run a production cloud, you should highly consider using RHOSP and paying Red Hat for support.

The associated articles can be found at:
- [Deploying RDO OpenStack in a Cohesive Manner. Part 1: Undercloud Deployment and Node Preparation](https://kdjlab.com/deploying-rdo-in-a-cohesive-manner/)
- []()

## Repository Layout

|- deploy.sh

This is a bash script that holds the openstack overcloud deploy command. It is extremely important to version control this command as it must be run with the same parameters while doing day 2 operations. You may also wish to keep different variations of this file for different deployment configurations.

|- downloadNodeData.sh

This is a simple bash script that downloads the inspection data for the overcloud nodes and places it into /home/stack/nodes/ on the undercloud. This is useful for determining what hardware is detected by the inspection process for nics, cpu, hard drives, etc. A very common task is to determine which hard drive was selected as the root device as you may want to change this.

|- instackenv.json

This file is a json representation of the overcloud nodes for importing into Ironic on the undercloud. For small labs, using files like this is fine, but if you have larger scale, you may consider using [TripleO's Auto Discovery feature](https://docs.openstack.org/project-deploy-guide/tripleo-docs/latest/provisioning/node_discovery.html).

|- templates/

This directory keeps all of the modified or custom overcloud environment files for the openstack overcloud deploy command. It is best practice to keep only those files that have been modified or created custom in this directory. This allows you to control the surface of files that you need to investigate if troubleshooting issues.

|- undercloud.conf

This file contains the complete configuration that is used by the openstack undercloud install command.
