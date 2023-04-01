output "nlb-target-group-arn" {
  description = "Target group arn"
  value = [for target in aws_lb_target_group.nlb-target-group: target.arn]
}

output "sg" {
  description = "security group id"
  value = [for sg in aws_security_group.nlb-sg: sg.id]
}
