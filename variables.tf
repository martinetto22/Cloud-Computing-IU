variable "secondary-VPCs-cidr_block" {
  description = "cidr_block of each VPC for the calculation zones"
  type = list(string)
  default = [ "172.1.0.0/16", "172.2.0.0/16", "172.3.0.0/16" ]
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
  description = "HTTPS listening port "
  type = number
  default = 80

  validation {
    condition = var.HTTP-server-port > 0 && var.HTTP-server-port <= 65536
    error_message = "Error in the HTTP port. Any port must be between 1 and 65536"
  }
}

variable "lb-port" {
  description = "Load balancer listening port"
  type = number
  default = 443

  validation {
    condition = var.lb-port > 0 && var.lb-port <= 65536
    error_message = "Error in the load balancer port. Any port must be between 1 and 65536"
  }
}

variable "instance-type" {
    description = "Type of instance to use"
    type = string
    default = "t2.micro"
}

variable "ubuntu_ami"{
    description = "Ubuntu ami for an specific ragion"
    type = map(string)

    default = {
        eu-west-3 = "ami-0afd55c0c8a52973a",
        eu-west-2 = "ami-0ad97c80f2dfe623b",
        #eu-west-2 = "ami-0aaa5410833273cfe"
    }
}