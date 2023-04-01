output "instances_id" {
  description = "ids of each instance"
  value = [for server in aws_instance.servers: server.id]
}
