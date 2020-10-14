
data "aws_route53_zone" "zone" {
  name  = var.domain_name
}

resource "aws_route53_record" "lower_tiers_records" {
  name = var.env
  type = "A"
  zone_id = data.aws_route53_zone.zone.zone_id
  alias {
    evaluate_target_health = false
    name = aws_lb.alb.dns_name
    zone_id = aws_lb.alb.zone_id
  }
}

//resource "aws_route53_record" "api" {
//  name = "api-${var.env}"
//  type = "A"
//  zone_id = data.aws_route53_zone.zone.zone_id
//  alias {
//    evaluate_target_health = false
//    name = aws_lb.alb.dns_name
//    zone_id = aws_lb.alb.zone_id
//  }
//}
