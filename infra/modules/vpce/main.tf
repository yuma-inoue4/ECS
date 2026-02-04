resource "aws_vpc_endpoint" "main" {
  tags              = { Name = var.name }
  vpc_id            = var.vpc_id
  for_each          = var.vpces
  vpc_endpoint_type = each.value.vpc_endpoint_type

  ### 共通 ###
  # (OP)サービス名(型式:com.amazonaws.<リージョン>.<サービス>)
  service_name = each.value.service_name
  # (OP)アクセス制限のポリシーをアタッチ(デフォルトはフルアクセス)
  policy = each.value.policy

  ### インターフェース型 ###
  # (OP) ENIに対する通行許可ルールを定義
  security_group_ids = each.value.security_group_ids
  # (OP) ENIをどのサブネットに配置するか
  subnet_ids = each.value.subnet_ids
  # (OP) 指定されたVPCにプライベートホストゾーンを関連付けるか否か(デフォルトはfalse)
  private_dns_enabled = each.value.private_dns_enabled

  ### ゲートウェイ型 ###
  # (OP) どのRouteTableに接続するか
  route_table_ids = each.value.route_table_ids
}
