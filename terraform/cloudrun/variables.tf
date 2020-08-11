
variable "gcp_auth_file" {
  type        = string
  description = "GCP authentication file"
}

variable "gcp_region" {
  type        = string
  description = "GCP region"
}

variable "gcp_project" {
  type        = string
  description = "GCP project name"
}
variable "stack_name" {
  description = "project name"
  type = string
}

variable "env" {
  type = string
  description = "environment or tier"
}
variable "machine_type" {
  description = "compute instance type"
  type = string
}

variable "subnet_range" {
  description = "subnet cidr for gke nodes"
  type = string
}

variable "subnets" {
  type = map(string)
}
variable "ssh_user" {
  description = "ssh user "
  type = string
}
variable "public_ssh_key" {
  description = "name of public ssh key file"
  type = string
}
variable "private_ssh_key" {
  description = "name of private ssh key file"
  type = string
}
variable "connector_network" {
  description = "vpc access network"
  type = string
}
variable "project_services" {
  description = "services to enable on this project"
  type = map(string)
}

variable "service_account_id" {
  description = "service account id"
  type = string
}
variable "db_password" {
  description = "set password for the neo4j user"
  type = string
}
variable "tag_name" {
  description = "name of docker tag"
  type = string
}