variable "subnets-id" {
  description = "ID of the private subnets for calculation servers"
  type = list(string)
}

variable "launch-template-id" {
  description = "Template to launch calculation instances"
  type = list(string)
}

variable "nlb-arn" {
  description = "ARN of the NLB target group"
  type = list(string)
}