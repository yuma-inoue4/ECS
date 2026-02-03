# memo:
# SGのmoduleを切り分けた理由 → ライフサイクルの違い
# SGはアプリの構成変更に伴って追加・変更されるため

#--------------------------------
# SG
#--------------------------------
### security group ###
resource "aws_security_group" "main" {
  vpc_id = var.vpc_id
  tags   = { Name = "${var.name}" }
  name   = var.name
}

### security group rule ###
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