
output "webapp_lb" {
  value = aws_lb.loadbalancer_EC2.dns_name
}
