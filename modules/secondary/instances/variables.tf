variable "ami-id" {
  description = "AMI id"
  type = string
}

variable "instance-type" {
  description = "Instance type"
  type = string
}

variable "vpc-ids" {
  description = "ids of the secondary VPCs"
  type = list(string)
}

variable "SSH-server-port" {
  description = "SSH listening port"
  type = number
}

variable "calculation-instances-map" {
  description = "Servers by default"
  type = map(object({
      name = string,
      subnet_id = string,
      ip = string,
  }))
}

variable "from-main-vpc" {
  description = "cidr block of the main VPC"
  type = string
  default = "172.0.0.0/16"
}

variable "instance-profile-name" {
  description = "IAM role name"
  type = string
}

variable "arn-instance-profile" {
  description = "ARN of the instance profile"
  type = string
}

variable "private-subnets" {
  description = "List with id of private subnets"
  type = list(string)
}

variable "sg-nlb" {
  description = "NLB sg ids"
  type = list(string)
}