#######################################################################
######################## ROUTE 53 DEFINITION ##########################

# ---------------------------------
# Taking the ID of the hosted zone
# ---------------------------------
data "aws_route53_zone" "default"{
    name = "PUT HERE YOUR DOMAIN NAME"
}

# ------------------
# Route 53 resource
# ------------------
resource "aws_route53_record" "example" {
  zone_id = data.aws_route53_zone.default.zone_id
  name = "DOMAIN NAME HERE"
  type = "A"
  alias {
    name                   = var.lb_dns_name
    zone_id                = var.lb_zone_id
    evaluate_target_health = false
  }
}
