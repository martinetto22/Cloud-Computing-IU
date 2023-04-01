#########################################################################
#########################################################################
########## Definition of all the networking in the main VPC##############
#########################################################################
#########################################################################

# ------------------------------------------------------------------
# Public subnets, here will be the servers of the application
# no the calculation servers
# ------------------------------------------------------------------
resource "aws_subnet" "public-subnets"{
  for_each = var.public-subnets

  vpc_id = var.vpc-id
  availability_zone = "${var.region}${each.value.availability_zone}"
  cidr_block = each.value.cidr_block

  tags = {
    Name = each.value.name
  }
}

# ---------------------------------------------------------------------
# Definition of the private subnets. In this subnets there will be only
# an endpoint to sccess S3 buckets
# ---------------------------------------------------------------------
resource "aws_subnet" "private-subnets"{
  for_each = var.private-subnets

  vpc_id = var.vpc-id
  availability_zone = "${var.region}${each.value.availability_zone}"
  cidr_block = each.value.cidr_block

  tags = {
    Name = each.value.name
  }
}

# -----------------
# Internet gateway
# -----------------
resource "aws_internet_gateway" "internet-gw" {
  vpc_id = var.vpc-id
}

# -------------------------------------------------------------------------
# Default route table of the main VPC. Routes defined:
# If 0.0.0.0/0 to internet gateway
# If any adress belonging to any secondary VPC, send to peering connection
# There are multiple routes to peering. One for each secondary subnet
# -------------------------------------------------------------------------
resource "aws_default_route_table" "route-table"{
    default_route_table_id = var.default-rt-id

    route{
      cidr_block = "0.0.0.0/0"
      gateway_id = aws_internet_gateway.internet-gw.id
    }

    count = length(aws_vpc_peering_connection.peering-connection)
    route {
      cidr_block = var.secondary-VPCs-block[count.index]
      vpc_peering_connection_id = aws_vpc_peering_connection.peering-connection[count.index].id
    }

  depends_on = [aws_vpc_peering_connection.peering-connection]
}

# ------------------------------------------------------------
# Private subnes route table
# ------------------------------------------------------------
resource "aws_route_table" "private-subnets-rt" {
  vpc_id = var.vpc-id

  tags = {
    Name = "Private subnet 1 route table"
  }

}

# ---------------------------------------------
# Association between subnets and route tables
# ---------------------------------------------

resource "aws_route_table_association" "private-subnet-associations" {
  for_each = var.private-subnets

  subnet_id      = aws_subnet.private-subnets[each.key].id
  route_table_id = aws_route_table.private-subnets-rt.id
}

#peering connection
resource "aws_vpc_peering_connection" "peering-connection" {
  count = length(var.vpc-ids)

  peer_vpc_id   = var.vpc-ids[count.index]
  vpc_id        = var.vpc-id
  auto_accept   = true

  tags = {
    Name = "VPC Peering between main and secondary VPCs"
  }
}