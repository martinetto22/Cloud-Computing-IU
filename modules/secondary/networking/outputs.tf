output "calculation-servers" {
  description = "ids of each instance"
  value = {
    for key, atr in var.calculation-instances-map:
    key => {name = atr.name, subnet_id = aws_subnet.private-subnets[key].id, ip = atr.ip }
  }
}

output "private-subnets-rt-ids" {
  description = "Private subnets rt"
  value = aws_default_route_table.secondaryVPCs-route-table[*].id
}

output "subnets-ids" {
  description = "ID of subnets"
  value = [for subnet in aws_subnet.private-subnets: subnet.id]
}
