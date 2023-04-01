output "load-balancer-dns" {
  description = "Load Balancer public DNS"
  value = module.loadbalancer.load-balancer-dns
}