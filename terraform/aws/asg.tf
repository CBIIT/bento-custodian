
resource "aws_launch_configuration" "asg_launch_config_custodian" {
  name              = "${var.stack_name}-launch-configuration"
  image_id          =  data.aws_ami.centos.id
  instance_type     =  var.fronted_instance_type
  iam_instance_profile = aws_iam_instance_profile.ecs-instance-profile.id
  security_groups   = [aws_security_group.frontend_sg.id]
  associate_public_ip_address = var.associate_public_ip_address
  key_name    = var.ssh_key_name
  user_data   = data.template_cloudinit_config.user_data.rendered
  root_block_device {
    volume_type   = var.evs_volume_type
    volume_size   = var.instance_volume_size
    delete_on_termination = true
  }

  lifecycle {
    create_before_destroy = true
  }

}

resource "aws_autoscaling_group" "asg_frontend" {
  name                 = join("-",[var.stack_name,var.frontend_asg_name,"asg"])
  max_size = var.max_size
  min_size = var.min_size
  desired_capacity     = var.desired_ec2_instance_capacity
  vpc_zone_identifier  = aws_subnet.private_subnet.*.id
  launch_configuration = aws_launch_configuration.asg_launch_config_custodian.name
  target_group_arns    = [aws_lb_target_group.frontend_target_group.arn,aws_lb_target_group.backend_target_group.arn]
  health_check_type    =  var.health_check_type
  tag {
    key = "Name"
    propagate_at_launch = true
    value = "${var.stack_name}-${var.frontend_asg_name}"
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

resource "aws_security_group" "frontend_sg" {
  name = "${var.stack_name}-frontend-sg"
  vpc_id = aws_vpc.vpc.id
  tags = merge(
  {
    "Name" = format("%s-frontend-sg",var.stack_name),
  },
  var.tags,
  )
}

resource "aws_security_group_rule" "inbound_bastion_frontend" {
  from_port = local.bastion_port
  protocol = local.tcp_protocol
  to_port = local.bastion_port
  security_group_id = aws_security_group.frontend_sg.id
  source_security_group_id = aws_security_group.bastion-sg.id
  type = "ingress"
}

resource "aws_security_group_rule" "inbound_frontend_alb" {
  from_port = var.frontend_container_port
  protocol = local.tcp_protocol
  to_port = var.frontend_container_port
  security_group_id = aws_security_group.frontend_sg.id
  source_security_group_id = aws_security_group.alb-sg.id
  type = "ingress"
}

resource "aws_security_group_rule" "inbound_backend_alb" {
  from_port = var.backend_container_port
  protocol = local.tcp_protocol
  to_port = var.backend_container_port
  security_group_id = aws_security_group.frontend_sg.id
  source_security_group_id = aws_security_group.alb-sg.id
  type = "ingress"
}

resource "aws_security_group_rule" "all_outbound_frontend" {
  from_port = local.any_port
  protocol = local.any_protocol
  to_port = local.any_port
  cidr_blocks = local.all_ips

  security_group_id = aws_security_group.frontend_sg.id
  type = "egress"
}

#create alb target group
resource "aws_lb_target_group" "frontend_target_group" {
  name = "${var.stack_name}-frontend-target"
  port = var.frontend_container_port
  protocol = "HTTP"
  vpc_id = aws_vpc.vpc.id
  stickiness {
    type = "lb_cookie"
    cookie_duration = 1800
    enabled = true
  }
  health_check {
    path = "/"
    protocol = "HTTP"
    matcher = "200"
    interval = 15
    timeout = 3
    healthy_threshold = 2
    unhealthy_threshold = 2
  }
  tags = merge(
  {
    "Name" = format("%s-%s",var.stack_name,"frontend-alb-target-group")
  },
  var.tags,
  )
}

#create alb target group
resource "aws_lb_target_group" "backend_target_group" {
  name = "${var.stack_name}-backend-target"
  port = var.backend_container_port
  protocol = "HTTP"
  vpc_id = aws_vpc.vpc.id
  stickiness {
    type = "lb_cookie"
    cookie_duration = 1800
    enabled = true
  }
  health_check {
    path = "/ping"
    protocol = "HTTP"
    matcher = "200"
    interval = 15
    timeout = 3
    healthy_threshold = 2
    unhealthy_threshold = 2
  }
  tags = merge(
  {
    "Name" = format("%s-%s",var.stack_name,"backend-alb-target")
  },
  var.tags,
  )
}

resource "aws_lb_listener_rule" "frontend_alb_listener" {
  listener_arn = aws_lb_listener.listener_http.arn
  priority = var.fronted_rule_priority
  action {
    type = "forward"
    target_group_arn = aws_lb_target_group.frontend_target_group.arn
  }

   condition {
    path_pattern  {
      values = ["/*"]
    }
  }

}

resource "aws_lb_listener_rule" "backend_alb_listener" {
  listener_arn = aws_lb_listener.listener_http.arn
  priority = var.alb_rule_priority
  action {
    type = "forward"
    target_group_arn = aws_lb_target_group.backend_target_group.arn
  }

  condition {
    path_pattern  {
      values = ["/v1/graphql/*"]
    }
  }
}

#create boostrap script to hook up the node to ecs cluster
resource "aws_ssm_document" "configure_server" {
  name          = "${var.stack_name}-bootstrap-ecs"
  document_type = "Command"
  document_format = "YAML"
  content = <<DOC
---
schemaVersion: '2.2'
description: State Manager Bootstrap Example
parameters: {}
mainSteps:
- action: aws:runShellScript
  name: configureServer
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
    - ansible-playbook ecs-agent.yml -e ecs_cluster_name="${var.ecs_cluster_name}" -e stack_name="${var.stack_name}" -e region="${var.region}"
    - systemctl restart docker
DOC
  tags = merge(
  {
    "Name" = format("%s-%s",var.stack_name,"ssm-document")
  },
  var.tags,
  )
}

#Deploy bento
resource "aws_ssm_document" "deploy_app" {
  name          = "${var.stack_name}-deploy-app"
  document_type = "Command"
  document_format = "YAML"
  content = <<DOC
---
schemaVersion: '2.2'
description: State Manager Bootstrap Example
parameters: {}
mainSteps:
- action: aws:runShellScript
  name: DeployApp
  inputs:
    runCommand:
    - set -ex
    - cd /tmp/bento-custodian/ansible
    - ansible-playbook deploy-custodian.yml -e ecr="${aws_ecr_repository.ecr.repository_url}" -e neo4j_ip="${aws_instance.db.private_ip}" -e region="${var.region}" -e neo4j_password="${var.database_password}" -e alb_dns_name="${aws_lb.alb.dns_name}" -e stack_name="${var.stack_name}"  -e cluster_name="${var.ecs_cluster_name}" -e backend_repo="${var.backend_repo}"  -e frontend_repo="${var.frontend_repo}"
  DOC
  tags = merge(
  {
    "Name" = format("%s-%s",var.stack_name,"bento-install-agents")
  },
  var.tags,
  )
}

resource "aws_ssm_document" "bootstrap" {
  document_format = "YAML"
  document_type = "Command"
  name = "boostrap-${var.stack_name}-ecs-instances"
  content = <<DOC
---
schemaVersion: '2.2'
description: Bootstrap ecs instances
parameters: {}
mainSteps:
- action: aws:runDocument
  name: configureServer
  inputs:
    documentType: SSMDocument
    documentPath: ${var.stack_name}-bootstrap-ecs
    documentParameters: "{}"
- action: aws:runDocument
  name: DeployApp
  inputs:
    documentType: SSMDocument
    documentPath: ${var.stack_name}-deploy-app
    documentParameters: "{}"

DOC
  tags = merge(
  {
    "Name" = format("%s-%s",var.stack_name,"bootstrap-ecs-instances")
  },
  var.tags,
  )
}


resource "aws_ssm_association" "boostrap" {
  name = aws_ssm_document.bootstrap.name
  targets {
    key   = "tag:aws:autoscaling:groupName"
    values = [aws_autoscaling_group.asg_frontend.name]
  }
  depends_on = [aws_autoscaling_group.asg_frontend]
}