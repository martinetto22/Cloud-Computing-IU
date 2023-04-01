##################################################################
# Module with all the configuations of the secondary VPC/subnets
# networking
##################################################################


resource "aws_subnet" "private-subnets"{
  count = length(var.vpc-ids)

  vpc_id = var.vpc-ids[count.index]
  availability_zone = "${var.region}${var.az-private-subnets[count.index]}"
  cidr_block = var.cidr-blocks-private-subnets[count.index]

  tags = {
    Name = var.names-private-subnets[count.index]
  }
}

#Default route table from secondary VPC
resource "aws_default_route_table" "secondaryVPCs-route-table" {
  count = length(var.vpc-ids)

  default_route_table_id = var.default-rt-ids[count.index]

  route {
    cidr_block = "0.0.0.0/0"
    vpc_peering_connection_id = var.peering-id[count.index]
  }

  tags = {
    Name = "Route table peering Secondary VPCs"
  }
}


