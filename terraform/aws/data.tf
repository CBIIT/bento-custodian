data "aws_caller_identity" "account" {
}

#grab latest centos ami
data "aws_ami" "centos" {
  most_recent = true

  filter {
    name   = "name"
    values = ["CentOS Linux 7 x86_64 HVM EBS *"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }
  owners   = ["679593333241"]
}

#define user data
data "template_cloudinit_config" "user_data" {
  gzip          = false
  base64_encode = false
  part {
    content = <<EOF
#cloud-config
---
users:
  - name: "${local.devops_user}"
    gecos: "${local.devops_user}"
    sudo: ALL=(ALL) NOPASSWD:ALL
    groups: wheel
    shell: /bin/bash
    ssh_authorized_keys:
    - "${tls_private_key.privkey.public_key_openssh}"
EOF
  }

  part {
    content_type = "text/x-shellscript"
    content      = file("${path.module}/ssm.sh")
  }
}

//data "aws_subnet" "az" {
//  vpc_id = aws_vpc.vpc.id
//  availability_zone = var.availability_zone
//  filter {
//    name = "tag:Name"
//    values = ["${var.stack_name}-private-${var.availability_zone}"]
//  }
////  filter {
////    name = "tag:Environment"
////    values = [
////      var.env]
////  }
//}