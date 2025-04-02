output "alb_dns_name" {
  description = "The DNS name of the load balancer"
  value       = aws_lb.web.dns_name
}

output "web_server_sg_id" {
  description = "The ID of the web server security group"
  value       = aws_security_group.web.id
}
