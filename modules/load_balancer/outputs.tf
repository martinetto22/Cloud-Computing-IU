/*output "load-balancer-dns" {
  description = "Load Balancer public DNS"
  value = "http://${aws_lb.app-lb.dns_name}:${var.lb-port}"
}*/

output "load-balancer-dns" {
  description = "Load Balancer public DNS"
  value = aws_lb.app-lb.dns_name
}

output "load-balancer-zone-id" {
  description = "Load Balancer zone ID"
  value = aws_lb.app-lb.zone_id
}

output "load-balancer-arn" {
  description = "Load Balancer arn"
  value = aws_lb.app-lb.arn
}