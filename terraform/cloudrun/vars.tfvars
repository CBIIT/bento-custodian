gcp_auth_file = "gcloud_api_key.json"
gcp_region = "us-east4"
gcp_project = "ppdc-cloud"
stack_name = "ppdc"
machine_type = "n1-standard-1"
env = "test"

service_account_id = "ppdc-sa"
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
#vpc connector network
connector_network = "10.8.0.0/28"

#ssh user to connect bastion host
ssh_user = "bento"

#name of ssh key
ssh_key_name = "demo-ssh-key"

#password of the neo4j database
db_password = "custodian"

#tag name of the docker image
image_tag = "release"

#specify the url of the bento backend repository
backend_repo = "https://github.com/CBIIT/bento-backend"

#specify the url of the bento frontend repository
frontend_repo = "https://github.com/CBIIT/bento-frontend"

#specify the url of the bento data repositor
data_repo = "https://github.com/CBIIT/bento-demo-data-model"

#specify dataset to be use
dataset = "Bento_Mock_Data_for_PACT1"

#specify data schema model file name if changed from default
model_file_name = "bento_tailorx_model_file.yaml"

# specify data schema properties file if changed from default
property_filename = "bento_tailorx_model_properties.yaml"
