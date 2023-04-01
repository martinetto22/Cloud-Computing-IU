output "name-instance-profile" {
  description = "Role for instances"
  value = aws_iam_instance_profile.dev-resources-iam-profile.name
}

output "arn-instance-profile" {
  description = "instance profile ARN"
  value = aws_iam_instance_profile.dev-resources-iam-profile.arn
}
