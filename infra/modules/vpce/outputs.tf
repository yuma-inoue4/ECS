output "vpc_endpoint_ids" {
  value = { for k, v in aws_vpc_endpoint.main : k => v.id }
}
