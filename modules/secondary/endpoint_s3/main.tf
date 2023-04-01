# ----------------------------------------------------------------------
# Creation endpoints and private subnets route tables
# ----------------------------------------------------------------------

# Enpoint S3
resource "aws_vpc_endpoint" "s3" {
  count = length(var.vpcs-id)

  vpc_id            = var.vpcs-id[count.index]
  service_name      = "com.amazonaws.eu-west-2.s3"
}

# ----------------------------------------------------------
# Association of the route tables to the bucket S3
# ----------------------------------------------------------

resource "aws_vpc_endpoint_route_table_association" "route-private-subnets-S3" {
  count = length(var.vpcs-id)

  route_table_id = var.private-subnets-rt-id[count.index]
  vpc_endpoint_id = aws_vpc_endpoint.s3[count.index].id
}