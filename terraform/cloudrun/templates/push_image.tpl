#!/bin/bash
set -ex
cd /tmp
rm -rf bento-custodian || true
yum -y install epel-release
yum -y install wget git python python-setuptools python-pip
pip install --upgrade "pip < 21.0"
pip install ansible==2.8.0
git clone https://github.com/CBIIT/bento-custodian
cd /tmp/bento-custodian/ansible
CLOUDSDK_CORE_DISABLE_PROMPTS=1 gcloud auth activate-service-account --key-file /tmp/${gcp_auth_file}
ansible-playbook docker.yml
ansible-playbook push-image.yml -e gcp_region=${gcp_region} -e env=${env} -e gcp_project=${gcp_project}
