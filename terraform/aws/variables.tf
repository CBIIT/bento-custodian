variable "tags" {
  description = "tags for the vpc"
  type = map(string)
}

variable "profile" {
  description = "iam profile to use"
  type = string
}
variable "region" {
  description = "availability region to use"
  type = string
}
variable "vpc_cidr_block" {
  description = "CIDR Block for this  VPC. Example 10.0.0.0/16"
  default = "10.10.0.0/16"
  type = string
}
variable "stack_name" {
  description = "Name of project. Example arp"
  type = string
  default = "main"
}
variable "custom_vpc_tags" {
  description = "Custom tags for the vpc"
  type = map(string)
  default = {}
}
variable "custom_igw_tags" {
  description = "Custom tags for the vpc"
  type = map(string)
  default = {}
}
variable "custom_private_tags" {
  description = "Custom tags for the private subnet"
  type = map(string)
  default = {}
}
variable "custom_public_tags" {
  description = "Custom tags for the public subnet"
  type = map(string)
  default = {}
}
variable "custom_db_tags" {
  description = "Custom tags for the database subnet"
  type = map(string)
  default = {}
}
variable "custom_nat_gateway_tags" {
  description = "Custom tags for the database subnet"
  type = map(string)
  default = {}
}
variable "custom_db_subnet_group_tags" {
  description = "Custom tags for the database subnet group"
  type = map(string)
  default = {}
}
variable "enable_hostname_dns" {
  description = "use true or false to determine support for hostname dns"
  type = bool
  default = true
}
variable "instance_tenancy" {
  description = "instances tenancy option. Options are dedicated or default"
  default     = "default"
  type = string
}

variable "alb_name" {
  description = "Name for the ALB"
  type = string
  default = "alb"
}
variable "create_alb" {
  description = "choose to create alb or not"
  type = bool
  default = true
}
variable "lb_type" {
  description = "Type of loadbalance"
  type = string
  default = "application"
}
variable "internal_alb" {
  description = "is this alb internal?"
  default = false
  type = bool
}

variable "ssl_policy" {
  description = "specify ssl policy to use"
  default = "ELBSecurityPolicy-2016-08"
  type = string
}
variable "default_message" {
  description = "default message response from alb when resource is not available"
  default = "The requested resource is not available"
}

variable "public_subnets" {
  description = "Provide list of public subnets to use in this VPC. Example 10.0.1.0/24,10.0.2.0/24"
  default     = []
  type = list(string)
}

variable "private_subnets" {
  description = "Provide list private subnets to use in this VPC. Example 10.0.10.0/24,10.0.11.0/24"
  default     = []
  type = list(string)
}

variable "create_vpc" {
  description = "Use true or false to determine if a new vpc is to be created"
  type = bool
  default = true
}
variable "env" {
  description = "specify environment for this vpc"
  type = string
  default = ""
}
variable "single_nat_gateway" {
  description = "Choose as to wherether you want single Nat Gateway for the environments or multiple"
  type        = bool
  default     = true
}
variable "one_nat_gateway_per_az" {
  description = "Choose as to wherether you want one Nat Gateway per availability zone or not"
  type        = bool
  default     = false
}
variable "availaiblity_zones" {
  description = "list of availability zones to use"
  type = list(string)
  default = []
}
variable "create_db_subnet_group" {
  description = "Set to true if you want to create database subnet group for RDS"
  type = bool
  default = true
}
variable "name_db_subnet_group" {
  default = "db-subnet"
  type = string
  description = "name of the db subnet group"
}

variable "reuse_nat_ips" {
  description = "Choose wherether you want EIPs to be created or not"
  type        = bool
  default     = false
}

variable "external_nat_ip_ids" {
  description = "List of EIP to be assigned to the NAT Gateways if you don't want to don't want to reuse existing EIP"
  type        = list(string)
  default     = []
}
variable "enable_nat_gateway" {
  description = "choose as to  provision NAT Gateways for each of your private subnets"
  type        = bool
  default     = true
}
variable "custom_public_route_table_tags" {
  description = "Custom tags for the vpc"
  type = map(string)
  default = {}
}
variable "custom_private_route_table_tags" {
  description = "Custom tags for the vpc"
  type = map(string)
  default = {}
}
variable "custom_private_subnet_tags" {
  description = "Custom tags for the vpc"
  type = map(string)
  default = {}
}
variable "custom_public_subnet_tags" {
  description = "Custom tags for the vpc"
  type = map(string)
  default = {}
}
variable "custom_db_subnet_tags" {
  description = "Custom tags for the vpc"
  type = map(string)
  default = {}
}
variable "enable_dns_support" {
  description = "enable dns resolution"
  type = bool
  default = true
}


variable "alb_rule_priority" {
  description = "priority number to assign to alb rule"
  type = number
}

variable "ecs_cluster_name" {
  description = "name of the ecs cluster"
}

variable "container_replicas" {
  description = "specify the number of container to run"
  type = number
}
variable "frontend_container_port" {
  description = "port on which the container listens"
  type = number
}
variable "backend_container_port" {
  description = "port on which the container listens"
  type = number
}

variable "fronted_instance_type" {
  description = "what size of instance to run"
  type = string
}
variable "min_size" {
  description = "minimum number of asg instances"
  type = number
}
variable "max_size" {
  description = "maximum number of asg instances"
  type = number
}
variable "enable_autoscaling" {
  description = "set to enable autoscaling"
  type = bool
  default = true
}
variable "health_check_type" {
  description = "The type of health check to use"
  type = string
  default = "EC2"
}
variable "associate_public_ip_address" {
  type = bool
  default = false
  description = "options to associate public ip to launched instances"
}
variable "evs_volume_type" {
  description = "EVS volume type"
  default = "standard"
  type = string
}
variable "instance_volume_size" {
  description = "volume size of the instances"
  type = number
}
variable "ssh_key_name" {
  description = "name of the ssh key to manage the instances"
  type = string
}
variable "desired_ec2_instance_capacity" {
  description = "number of ec2 to run workload ideally"
  type = number
}
variable "alb_port" {
  description = "Alb port to use in forwarding traffic to asg"
  type = number
  default = 80
}
variable "frontend_asg_name" {
  description = "name of the autoscalling group"
  type = string
  default = "front"
}
//variable "backend_asg_name" {
//  description = "name of the autoscalling group"
//  type = string
//}

variable "availability_zone" {
  description = "availability zone to provision"
  type = string
}
variable "fronted_rule_priority" {
  description = "priority number to assign to alb rule"
  type = number
  default = 110
}
variable "backend_rule_priority" {
  description = "priority number to assign to alb rule"
  type = number
  default = 100
}
variable "bastion_instance_type" {
  description = "ec2 instance type to use"
  type = string
}
variable "ssh_user" {
  type = string
  description = "name of the ec2 user"
}
variable "db_instance_volume_size" {
  description = "volume size of the instances"
  type = number
}

variable "database_name" {
  description = "name of the database"
  type = string
}
variable "database_instance_type" {
  description = "ec2 instance type to use"
  type = string
}
variable "database_password" {
  description = "set database password"
  type = string
  default = "custodian"
}

variable "backend_repo" {
  description = "bento backend repo url"
  type = string
}
variable "frontend_repo" {
  description = "bento backend repo url"
  type = string
}
variable "data_repo" {
  description = "bento data related repo url"
  type = string
}

variable "dataset" {
  description = "name of the dataset to be used."
  type = string
}

variable "model_file_name" {
  description = "specify data schema model file name if changed from default"
  type = string
}
variable "properties_file_name" {
  description = "specify data schema properties file if changed from default"
  type = string
}