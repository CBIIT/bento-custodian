#define any tags appropriate to your environment
tags = {
  ManagedBy = "terraform"
}
#specify vpc cidr 
vpc_cidr_block = "10.0.0.0/16"

#define private subnet to use
private_subnets = ["10.0.10.0/24"]

#define public subnets to use. Note you must specify at least two subnets
public_subnets = ["10.0.0.0/24","10.0.1.0/24"]

#enter the region in which your aws resources will be provisioned
region = "us-east-1"

#specify your aws credential profile. Note this is not IAM role but rather profile configure during AWS CLI installation 
profile = "custodian"

#specify the name you will like to call this project.
stack_name = "evay"

#specify availability zones to provision your resources. Note the availability zone must match the number of public subnets
availaiblity_zones = ["us-east-1a","us-east-1b"]


#provide the name of the ecs cluster 
ecs_cluster_name = "evay-cluster"

#specify the number of container replicas, minimum is 1
container_replicas = 1

#This is a port number for the bento-frontend 
frontend_container_port = 80

#This a port number for bento-backend
backend_container_port = 8080

#specify the maximum and minimun number of instances in auto-scalling group
max_size = 1
min_size = 1

#provide name for the auto-scalling-groups
frontend_asg_name = "frontend"
database_asg_name = "database"

desired_ec2_instance_capacity = 1

#cutomize the volume size for all the instances created except database
instance_volume_size = 40

#name of the ssh key imported in the deployment instruction
ssh_key_name = "jilivay"

#specify the aws compute instance type for the bento
fronted_instance_type = "t3.medium"

#provide the name of the admin user for ssh login
devops_user = "evay"

#availability zone 
availability_zone = "us-east-1a"

#specify the aws compute instance type for the database
database_instance_type =  "t3.medium"

#name of the database
database_name = "neo4j"

#specify the volume size for the database
db_instance_volume_size = 50

#alb priority rule number. This can be left as default
alb_rule_priority = 100

#specify neo4j database
database_password = "custodian"

#specify the name of the public ssh key parameter created in the deployment guide
ssh_public_key_filename = "bento-ssh-key.pub"

#specify the instance type of the bastion host
bastion_instance_type = "t2.micro"





