locals {
  http_port = 80
  any_port = 0
  any_protocol = "-1"
  tcp_protocol = "tcp"
  https_port = "443"
  all_ips  = ["0.0.0.0/0"]
  devops_user = var.devops_user
  bastion_port = 22
  neo4j_http = 7474
  neo4j_https = 7473
  neo4j_bolt = 7687
  ssm_iam_policy_arn = aws_iam_policy.ssm-policy.arn
}
locals {
  max_subnet_length = length(var.private_subnets)
  num_of_nat_gateway = var.single_nat_gateway ? 1 : var.one_nat_gateway_per_az ? length(var.availaiblity_zones) : local.max_subnet_length
  nat_gateway_ips = split(",", (var.reuse_nat_ips ? join(",", var.external_nat_ip_ids) : join(",", aws_eip.nat.*.id)))
}

