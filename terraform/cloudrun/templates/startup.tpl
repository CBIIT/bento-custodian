#!/bin/bash
set -ex
cd /tmp
rm -rf bento-custodian || true
yum -y install epel-release
yum -y install wget git python python-setuptools python-pip
pip install --upgrade "pip < 21.0"
pip install ansible==2.8.0
#echo "export PATH=$PATH:/usr/local/bin" > /etc/profile.d/ansible.sh && source /etc/profile.d/ansible.sh
git clone https://github.com/CBIIT/bento-custodian
cd bento-custodian/ansible
#CLOUDSDK_CORE_DISABLE_PROMPTS=1 gcloud auth activate-service-account --key-file /tmp/${gcp_auth_file}
#ansible-playbook docker.yml
ansible-playbook deploy-cloud-run.yml -e backend_url=${backend_url} -e release_tag=${image_tag} -e update=no -e frontend_repo=${frontend_repo} -e env=${env} -e backend_repo=${backend_repo} -e gcp_region=${gcp_region} -e neo4j_ip=${neo4j_ip} -e bearer='${bearer}' -e neo4j_password=${neo4j_password} -e gcp_project=${gcp_project}
