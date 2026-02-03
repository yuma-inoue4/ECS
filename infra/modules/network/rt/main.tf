resource "aws_route_table" "main" {
  vpc_id = var.vpc_id
  tags   = { Name = var.name }
}

resource "aws_route_table_association" "main" {
  for_each       = var.subnet_ids
  subnet_id      = each.value
  route_table_id = aws_route_table.main.id
}

resource "aws_route" "main" {
  route_table_id = aws_route_table.main.id

  # map(object)
  for_each               = var.routes
  destination_cidr_block = each.value.cidr_block
  network_interface_id   = each.value.network_interface_id
  gateway_id             = each.value.gateway_id
}