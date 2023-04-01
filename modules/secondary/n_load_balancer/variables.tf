variable "subnets-id" {
  description = "ID of the private subnets for calculation servers"
  type = list(string)
}

variable "vpc-id" {
  description = "ID of the VPCs"
  type = list(string)
}

variable "ssh-port" {
  description = "NLB port"
  type = number
}

variable "autoscaling-id" {
  description = "ID of the autoscaling groups"
  type = list(string)
}

variable "autoscaling-names" {
  description = "Names of the autoscaling groups"
  type = list(string)
}