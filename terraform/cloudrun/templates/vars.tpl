#Name of AWS region in which resources are located.
region: ${region}

# This is the password of the neo4j database provisioned using terraform.
neo4j_password: ${neo4j_password}

#The name of the project specified in vars.tfvars file.
stack_name: ${stack_name}


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

#specify vpc connector name
connector_name: ${connector_name}

#specify url to the backend container
backend_url: ${backend_url}

#indicate whether we're updating the app or not
update: "yes"

#name of gpc projects
gcp_project: ${gcp_project}