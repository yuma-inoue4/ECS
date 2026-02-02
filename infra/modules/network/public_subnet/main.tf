resource "aws_subnet" "public" {
  for_each   = var.public_subnets
  vpc_id     = var.vpc_id
  cidr_block = each.value
  tags       = { Name = "${each.key}-${var.name}" }
}