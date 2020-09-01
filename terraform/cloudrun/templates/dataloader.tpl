#!/bin/bash
set -ex
cd /tmp
rm -rf bento-custodian || true
git clone https://github.com/CBIIT/bento-custodian
cd bento-custodian/ansible
ansible-playbook data-loader.yml -e neo4j_ip=${neo4j_ip} -e neo4j_password=${neo4j_password} -e init_db=yes -e  data_repo=${data_repo}
