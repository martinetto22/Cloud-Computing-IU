variable "vpc-id" {
  description = "id of the main VPC"
  type = string
}

variable "SSH-server-port" {
  description = "SSH listening port"
  type = number
  default = 22

  validation {
    condition = var.SSH-server-port > 0 && var.SSH-server-port <= 65536
    error_message = "Error in the SSH port. Any port must be between 1 and 65536"
  }
}

variable "HTTP-server-port" {
  description = "HTTP listening port "
  type = number
  default = 80

  validation {
    condition = var.HTTP-server-port > 0 && var.HTTP-server-port <= 65536
    error_message = "Error in the HTTP port. Any port must be between 1 and 65536"
  }
}

variable "instance-type" {
    description = "Type of instance to use"
    type = string
}

variable "ami-id"{
    description = "AMI id"
    type = string
}

variable "servers-map" {
  description = "Map of servers with their subnets"
  type = map(object({
      name = string,
      subnet_id = string,
      ip = string
  }))
}


variable "instance-profile-name" {
  description = "IAM role name"
  type = string
}

variable "arn-instance-profile" {
  description = "ARN of the instance profile"
  type = string
}