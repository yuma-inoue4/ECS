resource "aws_subnet" "private" {
  for_each   = var.private_subnets
  vpc_id     = var.vpc_id
  cidr_block = each.value
  tags       = { Name = "${each.key}-${var.name}" }
}