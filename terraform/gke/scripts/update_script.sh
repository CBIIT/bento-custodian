#!/bin/bash
set -ex
cd /tmp
rm -rf bento-custodian || true
git clone https://github.com/CBIIT/bento-custodian
cd /tmp/bento-custodian/ansible
ansible-playbook deploy-cloud-run.yml -e neo4j_ip=${neo4j_ip} -e neo4j_password=${neo4j_password} -e gcp_project=${gcp_project} -e backend_url=${backend_url} -e tag=${tag}
