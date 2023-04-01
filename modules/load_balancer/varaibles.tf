variable "vpc-id" {
  description = "id of the main VPC"
  type = string
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

variable "lb-port" {
  description = "Load balancer listening port"
  type = number
  default = 443

  validation {
    condition = var.lb-port > 0 && var.lb-port <= 65536
    error_message = "Error in the load balancer port. Any port must be between 1 and 65536"
  }
}

variable "subnets_ids"{
    description = "Public Subnets"
    type = set(string)
}

variable "instances_ids" {
  description = "Instances id"
  type = list(string)
}