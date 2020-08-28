
#create security group
resource "aws_security_group" "bastion-sg" {
  name = "${var.stack_name}-bastion-sg"
  vpc_id = aws_vpc.vpc.id
  tags = merge(
  {
    "Name" = format("%s-bastion-host-sg",var.stack_name),
  },
  var.tags,
  )
}

#define inbound security group rule
resource "aws_security_group_rule" "inbound_bastion" {
  from_port = local.bastion_port
  protocol = local.tcp_protocol
  to_port = local.bastion_port
  cidr_blocks = local.all_ips
  security_group_id = aws_security_group.bastion-sg.id
  type = "ingress"
}

#define outbound security group rule
resource "aws_security_group_rule" "outbound_bastion" {
  from_port = local.any_port
  protocol = local.any_protocol
  to_port = local.any_port
  cidr_blocks = local.all_ips

  security_group_id = aws_security_group.bastion-sg.id
  type = "egress"
}

#provision bastion host
resource "aws_instance" "bastion_host" {
  ami            = data.aws_ami.centos.id
  instance_type  = var.bastion_instance_type
  vpc_security_group_ids   = [aws_security_group.bastion-sg.id]
  key_name                 = var.ssh_key_name
  subnet_id                = aws_subnet.public_subnet.*[0].id
  source_dest_check           = false
  iam_instance_profile = aws_iam_instance_profile.ecs-instance-profile.id
  user_data  = data.template_cloudinit_config.user_data.rendered

  tags = merge(
  {
    "Name" = format("%s-bastion-host",var.stack_name),
  },
  var.tags,
  )
}

resource "aws_eip" "bastion" {
  instance = aws_instance.bastion_host.id
  vpc      = true
}

