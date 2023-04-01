variable "vpcs-id" {
  description = "id of the secondary VPCs"
  type = list(string)
}

variable "private-subnets-rt-id" {
  description = "ids of private subnets route table"
  type = list(string)
}