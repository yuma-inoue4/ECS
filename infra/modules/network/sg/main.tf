resource "aws_security_group" "main" {
  vpc_id = var.vpc_id
  tags   = { Name = "${var.name}" }
  name   = var.name
}

resource "aws_security_group_rule" "main" {
  security_group_id = aws_security_group.main.id

  for_each                 = var.sgs
  type                     = each.value.type
  protocol                 = each.value.protocol
  from_port                = each.value.from_port
  to_port                  = each.value.to_port
  cidr_blocks              = each.value.cidr_blocks
  source_security_group_id = each.value.source_security_group_id
}
