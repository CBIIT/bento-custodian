gcp_auth_file = "gcloud_api_key.json"
gcp_region = "us-east4"
gcp_project = "bento-cloudrun"
stack_name = "bento"
machine_type = "n1-standard-1"
env = "demo"

service_account_id = "bento-sa"
project_services = {
  vpc_connector = "vpcaccess.googleapis.com"
  compute = "compute.googleapis.com"
  network = "servicenetworking.googleapis.com"
}
subnet_range = "10.10.0.0/16"
subnets = {
  mgmt-network = "172.16.1.0/24"
  db-network = "192.168.5.0/28"
}
connector_network = "10.8.0.0/28"
ssh_user = "bento"
public_ssh_key = "bento-ssh-key.pub"
private_ssh_key = "bento-ssh-key"
db_password = "custodian"
tag_name = "release"