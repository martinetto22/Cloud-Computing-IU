output "autoscaling-ids" {
  description = "ID of the autoscaling groups"
  value = [for autoscaling in aws_autoscaling_group.asg-calculation-instances: autoscaling.id]
}

output "autoscaling-names" {
  description = "Names of the autoscaling groups"
  value = [for autoscaling in aws_autoscaling_group.asg-calculation-instances: autoscaling.arn]
}