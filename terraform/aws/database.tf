
resource "aws_launch_configuration" "asg_launch_config" {
  name              = "${var.stack_name}-database-launch-configuration"
  image_id          =  data.aws_ami.centos.id
  instance_type     =  var.database_instance_type
  iam_instance_profile = aws_iam_instance_profile.ecs-instance-profile.id
  security_groups   = [aws_security_group.database-sg.id]
  associate_public_ip_address = var.associate_public_ip_address
  key_name    = var.ssh_key_name
  user_data   = data.template_cloudinit_config.user_data.rendered
  root_block_device {
    volume_type   = var.evs_volume_type
    volume_size   = var.db_instance_volume_size
    delete_on_termination = true
  }

  lifecycle {
    create_before_destroy = true
  }

}

resource "aws_autoscaling_group" "db_asg" {
  name                 = join("-",[var.stack_name,var.database_asg_name,"asg"])
  max_size = var.max_size
  min_size = var.min_size
  desired_capacity     = var.desired_ec2_instance_capacity
  vpc_zone_identifier  = aws_subnet.private_subnet.*.id
  launch_configuration = aws_launch_configuration.asg_launch_config.name
  health_check_type    =  var.health_check_type
  tag {
    key = "Name"
    propagate_at_launch = true
    value = "${var.stack_name}-${var.database_asg_name}"
  }
  dynamic "tag" {
    for_each = var.tags
    content {
      key = tag.key
      value = tag.value
      propagate_at_launch = true
    }
  }
}

#create database security group
resource "aws_security_group" "database-sg" {
  name = "${var.stack_name}-datagase-sg"
  description = "database security group"
  vpc_id = aws_vpc.vpc.id
  tags = merge(
  {
    "Name" = format("%s-%s",var.stack_name,"database-sg")
  },
  var.tags,
  )
}

resource "aws_security_group_rule" "neo4j_http" {
  from_port = local.neo4j_http
  protocol = local.tcp_protocol
  to_port = local.neo4j_http
  cidr_blocks = flatten([var.private_subnets])
  security_group_id = aws_security_group.database-sg.id
  type = "ingress"
}
resource "aws_security_group_rule" "bastion_host_ssh" {
  from_port = local.bastion_port
  protocol = local.tcp_protocol
  to_port = local.bastion_port
  source_security_group_id = aws_security_group.bastion-sg.id
  security_group_id = aws_security_group.database-sg.id
  type = "ingress"
}
resource "aws_security_group_rule" "neo4j_https" {
  from_port = local.neo4j_https
  protocol = local.tcp_protocol
  to_port = local.neo4j_https
  cidr_blocks = flatten([var.private_subnets])
  security_group_id = aws_security_group.database-sg.id
  type = "ingress"
}

resource "aws_security_group_rule" "neo4j_bolt" {
  from_port = local.neo4j_bolt
  protocol = local.tcp_protocol
  to_port = local.neo4j_bolt
  cidr_blocks = flatten([var.private_subnets])
  security_group_id = aws_security_group.database-sg.id
  type = "ingress"
}

resource "aws_security_group_rule" "all_outbound_database" {
  from_port = local.any_port
  protocol = local.any_protocol
  to_port = local.any_port
  cidr_blocks = local.all_ips
  security_group_id = aws_security_group.database-sg.id
  type = "egress"
}


#create boostrap script to hook up the node to ecs cluster
resource "aws_ssm_document" "ssm_neo4j_boostrap" {
  name          = "${var.stack_name}-setup-database"
  document_type = "Command"
  document_format = "YAML"
  content = <<DOC
---
schemaVersion: '2.2'
description: State Manager Bootstrap Example
parameters: {}
mainSteps:
- action: aws:runShellScript
  name: configureDatabase
  inputs:
    runCommand:
    - set -ex
    - cd /tmp
    - rm -rf bento-custodian || true
    - yum -y install epel-release
    - yum -y install wget git python-setuptools python-pip
    - pip install ansible==2.8.0 boto boto3 botocore
    - git clone https://github.com/CBIIT/bento-custodian
    - cd bento-custodian/ansible
    - ansible-playbook neo4j.yml
    - systemctl restart neo4j
DOC
  tags = merge(
  {
    "Name" = format("%s-%s",var.stack_name,"ssm-document")
  },
  var.tags,
  )
}


#load data
resource "aws_ssm_document" "load_data" {
  name          = "${var.stack_name}-load-data"
  document_type = "Command"
  document_format = "YAML"
  content = <<DOC
---
schemaVersion: '2.2'
description: State Manager Bootstrap Example
parameters: {}
mainSteps:
- action: aws:runShellScript
  name: LoadData
  inputs:
    runCommand:
    - set -ex
    - cd /tmp/bento-custodian/ansible
    - ansible-playbook data-loader.yml  -e neo4j_password="${var.database_password}"
  DOC
  tags = merge(
  {
    "Name" = format("%s-%s",var.stack_name,"load-bento-data")
  },
  var.tags,
  )
}

resource "aws_ssm_document" "bootstrap_database" {
  document_format = "YAML"
  document_type = "Command"
  name = "boostrap-${var.stack_name}-database"
  content = <<DOC
---
schemaVersion: '2.2'
description: Bootstrap database instances
parameters: {}
mainSteps:
- action: aws:runDocument
  name: configureDatabase
  inputs:
    documentType: SSMDocument
    documentPath: ${var.stack_name}-setup-database
    documentParameters: "{}"
- action: aws:runDocument
  name: LoadData
  inputs:
    documentType: SSMDocument
    documentPath: ${var.stack_name}-load-data
    documentParameters: "{}"

DOC
  tags = merge(
  {
    "Name" = format("%s-%s",var.stack_name,"load-data")
  },
  var.tags,
  )
}


resource "aws_ssm_association" "database" {
  name = aws_ssm_document.bootstrap_database.name
  targets {
    key   = "tag:aws:autoscaling:groupName"
    values = [aws_autoscaling_group.db_asg.name]
  }
  depends_on = [aws_autoscaling_group.db_asg]
}
