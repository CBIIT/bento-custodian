#grab certificate
data "aws_acm_certificate" "certificate" {
//  domain = join(".",["*",var.domain_name])
  domain = var.domain_name
  types  = ["AMAZON_ISSUED"]
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

#grab public ssh key
data "aws_ssm_parameter" "sshkey" {
  name = var.ssm_ssh_public_key_name
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
    - "${data.aws_ssm_parameter.sshkey.value}"
EOF
  }

  part {
    content_type = "text/x-shellscript"
    content      = "${file("ssm.sh")}"
  }
}
