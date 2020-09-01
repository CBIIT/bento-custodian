#Name of AWS region in which resources are located.
region: ${region}

# This is the password of the neo4j database provisioned using terraform.
neo4j_password: ${neo4j_password}

# The dns name of the Application loadbalancer
alb_dns_name: ${alb_dns_name}

#The name of the project specified in vars.tfvars file.
stack_name: ${stack_name}

# The name of the ECS cluster.
cluster_name: ${cluster_name}

#The url of the backend repository
backend_repo: ${backend_repo}

#The url of the frontend repository
frontend_repo: ${frontend_repo}

#The file name of the dataset if changed from the default
dataset: ${dataset}

#Do not change
init_db: no

#specify data schema properties file if changed from default
property_filename: ${property_filename}

#The url of the data-model repository
data_repo: ${data_repo}

#specify database private ip. This value is auto populated from terraform.
neo4j_ip: ${neo4j_ip}

#specify docker registry to be used. Note this document assumes you're using AWS ECR
ecr: ${ecr}

#This is an arbitrary tag for the final deployed application. This value shows at the bottom of the application on the index page
release_tag: master

#specify git tag for the forked backend repository
backend_tag: master

#specify git tag for the forked frontend repository
frontend_tag: master

#specify git tag for the forked data model repository
data_tag: master

#specify docker tag for both frontend and backend images
image_tag: release

#specify data schema model file name if changed from default
model_file_name: ${model_file_name}
