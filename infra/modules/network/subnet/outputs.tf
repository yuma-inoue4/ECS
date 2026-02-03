output "subnet_ids" {
  value = { for k, v in aws_subnet.main : k => v.id }
}