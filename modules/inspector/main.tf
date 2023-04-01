resource "aws_inspector2_enabler" "example" {
  account_ids    = ["YOUR ACCOUNT ID"]
  resource_types = ["EC2"]
}