
resource "aws_lb" "alb" {

  name = "${var.stack_name}-${var.alb_name}"
  load_balancer_type = var.lb_type
  subnets = aws_subnet.public_subnet.*.id
  security_groups = [aws_security_group.alb-sg.id]

  timeouts {
    create = "10m"
  }

  tags = merge(
  {
    "Name" = format("%s",var.stack_name)
  },
  var.tags,
  )
}

#create alb security group
resource "aws_security_group" "alb-sg" {

  name = "${var.stack_name}-alb-sg"
  vpc_id = aws_vpc.vpc.id
  tags = merge(
  {
    "Name" = format("%s",var.stack_name)
  },
  var.tags,
  )
}

resource "aws_security_group_rule" "inbound_http" {

  from_port = local.http_port
  protocol = local.tcp_protocol
  to_port = local.http_port
  cidr_blocks = local.all_ips

  security_group_id = aws_security_group.alb-sg.id
  type = "ingress"
}

//resource "aws_security_group_rule" "inbound_https" {
//
//  from_port = local.https_port
//  protocol = local.tcp_protocol
//  to_port = local.https_port
//  cidr_blocks = local.all_ips
//
//  security_group_id = aws_security_group.alb-sg.id
//  type = "ingress"
//}

resource "aws_security_group_rule" "all_outbound" {

  from_port = local.any_port
  protocol = local.any_protocol
  to_port = local.any_port
  cidr_blocks = local.all_ips

  security_group_id = aws_security_group.alb-sg.id
  type = "egress"
}

//#create https redirect
//resource "aws_lb_listener" "redirect_https" {
//
//  load_balancer_arn = aws_lb.alb.arn
//  port  = local.http_port
//  protocol  = "HTTP"
//  default_action {
//    type  = "redirect"
//    redirect {
//      port  = local.https_port
//      protocol  = "HTTPS"
//      status_code = "HTTP_301"
//    }
//  }
//}

resource "aws_lb_listener" "listener_http" {

  load_balancer_arn = aws_lb.alb.arn
  port   = local.http_port
  protocol   = "HTTP"

  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = var.default_message
      status_code  = "200"
    }
  }
}

