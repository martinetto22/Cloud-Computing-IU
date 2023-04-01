variable "vpc-id" {
  description = "id of the main VPC"
  type = string
}

variable "vpc-ids" {
  description = "ids of the secondary VPCs"
  type = list(string)
}

variable "secondary-VPCs-block" {
  description = "cidr_block of each secondary VPC"
  type = list(string)
}

variable "region" {
  description = "region"
  type = string
}

variable "default-rt-id" {
  description = "id of the default route table"
  type = string
}

variable "public-subnets"{
    description = "Public Subnets"
    type = map(object({
        name = string,
        availability_zone = string,
        cidr_block = string
    }))

    default = {
        "public-subnet-0" = {name = "Public subnet 0", availability_zone = "a", cidr_block = "172.0.0.0/24"},
        "public-subnet-1" = {name = "Public subnet 1", availability_zone = "b", cidr_block = "172.0.2.0/24"},
        "public-subnet-2" = {name = "Public subnet 2", availability_zone = "c", cidr_block = "172.0.4.0/24"},
        
    }
}

variable "private-subnets"{
    description = "Private Subnets"
    type = map(object({
        name = string,
        availability_zone = string,
        cidr_block = string
    }))

    default = {
        "private-subnet-0" = {name = "Private subnet 0", availability_zone = "a", cidr_block = "172.0.1.0/24"},
        "private-subnet-1" = {name = "Private subnet 1", availability_zone = "b", cidr_block = "172.0.3.0/24"}        
    }
}

variable "servers-map" {
  description = "Servers by default"
  type = map(object({
      name = string,
      subnet = string,
      ip = string
  }))

  default = {
    "server-0" = { subnet = "public-subnet-0", name = "server-0", ip = "172.0.0.4" },
    "server-1" = { subnet = "public-subnet-1", name = "server-1", ip = "172.0.2.4" },
    "server-2" = { subnet = "public-subnet-2", name = "server-2", ip = "172.0.4.4" }
  }
}