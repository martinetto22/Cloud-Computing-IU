output "servers" {
  description = "ids of each instance"
  value = {
    for k, atr in var.servers-map:
    k => {name = atr.name, subnet_id = aws_subnet.public-subnets[atr.subnet].id, ip = atr.ip }
  }
}

output "public-subnets-ids" {
  description = "Public subnets ids"
  value = [for subnet in aws_subnet.public-subnets: subnet.id]
}

output "private-subnets-rt-id" {
  description = "Private subnets rt"
  value = aws_route_table.private-subnets-rt.id
}

output "peering-connection-id" {
  description = "ID of the peering connection"
  value = [for connection in aws_vpc_peering_connection.peering-connection: connection.id]
}