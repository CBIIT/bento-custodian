#!/bin/bash
set -ex
cd /tmp
rm -rf bento-custodian || true
git clone https://github.com/CBIIT/bento-custodian
cd /tmp/bento-custodian/ansible
ansible-playbook push-image.yml -e gcp_region=${gcp_region} -e env=${env} -e gcp_project=${gcp_project}
