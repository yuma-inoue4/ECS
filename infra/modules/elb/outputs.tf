output "load_balancer_arn" {
  value = aws_lb.main.arn
}

output "tg_arn" {
  value = aws_lb_target_group.main.arn
}

output "dns_name" {
  value = aws_lb.main.dns_name
}