
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

variable "gke_username" {
  type = string
  description = "gke username"
}

variable "gke_password" {
type = string
  description = "gke password"
}

variable "gke_num_nodes" {
  type = number
  description = "number of gke nodes"
}
variable "env" {
  type = string
  description = "environment or tier"
}
variable "machine_type" {
  description = "compute instance type"
  type = string
}
//variable "bento_public_subnet" {
//  type = string
//  description = "public subnet"
//}
//variable "bento_private_subnet" {
//  type = string
//  description = "private subnet"
//}
variable "cluster_name" {
  description = "name of gke cluster"
  type = string
}
variable "iam_roles" {
  description = "iam role for gke"
  type = map(string)
}
variable "subnet_range" {
  description = "subnet cidr for gke nodes"
  type = string
}
variable "pod_range" {
  description = "subnet cidr for gke pods"
}
variable "service_range" {
  description = "subnet cidr for gke service"
}
variable "subnets" {
  type = map(string)
}
variable "ssh_user" {
  description = "ssh user "
  type = string
}
variable "ssh_key" {
  description = "public ssh key file directory "
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