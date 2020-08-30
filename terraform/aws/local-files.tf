resource "tls_private_key" "privkey" {
  algorithm = "RSA"
  rsa_bits = 4096
}
resource "aws_key_pair" "keypair" {
  key_name = var.ssh_key_name
  public_key = tls_private_key.privkey.public_key_openssh
}
resource "local_file" "private_key" {
  content = tls_private_key.privkey.private_key_pem
  file_permission = "0600"
  filename = "${path.module}/ansible/ssh_private_key.pem"
  depends_on = [aws_instance.bastion_host]
}

resource "local_file" "ansible_hosts" {
  content = templatefile("${path.module}/templates/hosts.tpl",
  {
    bastion_ip = aws_instance.bastion_host.public_ip
    ssh_user = var.ssh_user
    key_path = local_file.private_key.filename
  }
  )
  filename = "${path.module}/ansible/hosts"
  depends_on = [aws_instance.bastion_host]
}

resource "local_file" "ansible_vars" {
  content = templatefile("${path.module}/templates/vars.tpl",
  {
    region = var.region
    neo4j_password = var.database_password
    alb_dns_name = aws_lb.alb.dns_name
    stack_name = var.stack_name
    database_name = var.database_name
    cluster_name = var.ecs_cluster_name
    backend_repo = var.backend_repo
    frontend_repo = var.frontend_repo
    dataset = var.dataset
    data_repo = var.data_repo
    neo4j_ip = aws_instance.db.private_ip
    ecr = aws_ecr_repository.ecr.repository_url
  }
  )
  filename = "../../ansible/vars.yaml"
}