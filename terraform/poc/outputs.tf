output "bastion_host_ip" {
  value = aws_instance.bastion_host.public_ip
  description = "Elastic ip associated with basition host"
}
output "custodian_url" {
  value = aws_route53_record.records.fqdn
  description = "Custodian URL"
}
output "custodian_api_endpoint" {
  value = aws_route53_record.api.fqdn
  description = "Custodian API Endpoint"
}

output "admin_user" {
  value = var.devops_user
  description = "The admin user with ssh access"
}