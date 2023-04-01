variable "main-vpc-id" {
  description = "id of the main VPC"
  type = string
}

variable "vpc-ids" {
  description = "ids of the secondary VPCs"
  type = list(string)
}

variable "names-private-subnets"{
    description = "value"
    type = list(string)
    default = [ "Private subnet 0", "Private subnet 1", "Private subnet 2" ]
}

variable "az-private-subnets" {
  description = "value"
  type = list(string)
  default = [ "a", "b", "c" ]
}

variable "cidr-blocks-private-subnets" {
  description = "value"
  type = list(string)
  default = [ "172.1.0.0/24", "172.2.0.0/24", "172.3.0.0/24" ]
}

variable "region" {
  description = "region"
  type = string
}


variable "peering-id" {
  description = "value"
  type = list(string)
}

variable "default-rt-ids" {
  description = "IDs of the route tables"
  type = list(string)
}

variable "calculation-instances-map" {
  description = "Calculation servers by default"
  type = map(object({
      name = string,
      subnet = string,
      ip = string
  }))

  default = {
    "0" = { subnet = "private-subnet-0", name = "calculation-instance-0", ip = "172.1.0.4" },
    "1" = { subnet = "private-subnet-1", name = "calculation-instance-1", ip = "172.2.0.4" },
    "2" = { subnet = "private-subnet-2", name = "calculation-instance-2", ip = "172.3.0.4" }
  }
}