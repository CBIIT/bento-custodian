#!/bin/bash
set -ex
cd /tmp
rm -rf bento-custodian || true
yum -y install epel-release
yum -y install wget git python3-setuptools python3
pip3 install ansible==2.8.0 openshift
git clone https://github.com/CBIIT/bento-custodian
cd bento-custodian/ansible
CLOUDSDK_CORE_DISABLE_PROMPTS=1 gcloud auth activate-service-account --key-file /tmp/${gcp_auth_file}
gcloud container clusters get-credentials ${cluster_name} --zone=${gcp_region} --project=${gcp_project}
/usr/local/bin/ansible-playbook docker.yml --skip-tags master
/usr/local/bin/ansible-playbook deploy-gke.yml -e neo4j_ip=${neo4j_ip} -e neo4j_password=${neo4j_password} -e gcp_project=${gcp_project}
