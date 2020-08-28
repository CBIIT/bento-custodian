gcp_auth_file = "bento-apikey.json"
gcp_region = "us-east4"
gcp_project = "ctdc-demo"
stack_name = "ctdc"
gke_username = "bento-user"
gke_password = "OurBestDaysAreAhead2020"
gke_num_nodes = 1
machine_type = "n1-standard-1"
env = "dev"
cluster_name = "demo"
iam_roles  = {
  container_admin = "roles/container.admin"
  compute_admin = "roles/compute.admin"
  service_account = "roles/iam.serviceAccountUser"
  cloud_run = "roles/run.admin"
  cloud_functions = "roles/cloudfunctions.admin"
  vpc_connector = "roles/vpcaccess.admin"
  cloud_storage = "roles/storage.admin"
}
project_services = {
  vpc_connector = "vpcaccess.googleapis.com"
}
subnet_range = "10.10.0.0/16"
pod_range = "/20"
service_range = "/22"
subnets = {
  gke-network = "10.10.0.0/16"
  mgmt-network = "172.16.1.0/24"
  db-network = "192.168.5.0/28"
}
connector_network = "10.8.0.0/28"
ssh_user = "bento"
public_ssh_key = "bento-ssh-key.pub"
private_ssh_key = "bento-ssh-key"
db_password = "custodian"
tag_name = "release"
service_account_id = "demo-sa"