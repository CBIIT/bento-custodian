output "bastion_host_ip" {
  value = aws_instance.bastion_host.public_ip
  description = "Elastic ip associated with basition host"
}
output "custodian_url" {
  value = "http://${aws_lb.alb.dns_name}"
  description = "Custodian URL"
}
output "custodian_api_endpoint" {
  value = "http://${aws_lb.alb.dns_name}/api/graphql/"
  description = "Custodian API Endpoint"
}

output "admin_user" {
  value = var.devops_user
  description = "The admin user with ssh access"
}