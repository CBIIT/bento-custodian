#!/bin/bash
set -ex
cd /tmp
rm -rf bento-custodian || true
yum -y install epel-release
yum -y install wget git python-setuptools python-pip
pip install ansible==2.8.0
git clone https://github.com/CBIIT/bento-custodian
cd bento-custodian/ansible
CLOUDSDK_CORE_DISABLE_PROMPTS=1 gcloud auth activate-service-account --key-file /tmp/${gcp_auth_file}
ansible-playbook docker.yml
ansible-playbook deploy-cloud-run.yml -e update=no -e frontend_repo=${frontend_repo} -e backend_repo=${backend_repo}  -e neo4j_ip=${neo4j_ip} -e neo4j_password=${neo4j_password} -e gcp_project=${gcp_project}
