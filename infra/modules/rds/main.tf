#--------------------------------
# RDS
#--------------------------------
resource "aws_db_instance" "main" {
  # エンジン
  identifier        = var.rds_conf.identifier
  engine            = var.rds_conf.engine
  engine_version    = var.rds_conf.engine_version
  instance_class    = var.rds_conf.instance_class
  allocated_storage = var.rds_conf.allocated_storage
  storage_type      = var.rds_conf.storage_type

  # 接続情報
  db_name  = var.rds_conf.db_name
  username = var.rds_conf.username
  password = var.rds_conf.password

  # ネットワーク
  vpc_security_group_ids = var.rds_conf.vpc_security_group_ids
  db_subnet_group_name   = aws_db_subnet_group.main.name
  parameter_group_name   = aws_db_parameter_group.main.name
  publicly_accessible    = var.rds_conf.publicly_accessible

  # 冗長性
  skip_final_snapshot = var.rds_conf.skip_final_snapshot
  deletion_protection = var.rds_conf.deletion_protection
  apply_immediately   = var.rds_conf.apply_immediately
  multi_az            = var.rds_conf.multi_az

  # タグ
  tags = { Name = var.rds_conf.name }
}

#--------------------------------
# RDS / Subnet Group
#--------------------------------
resource "aws_db_subnet_group" "main" {
  name       = var.rds_conf.db_subnet_group_name
  subnet_ids = var.subnet_ids
  tags       = { Name = var.rds_conf.name }
}

#--------------------------------
# RDS / Parameter group
#--------------------------------
resource "aws_db_parameter_group" "main" {
  name   = var.rds_conf.parameter_group_name
  family = "${var.rds_conf.engine}${var.rds_conf.engine_version}" # エンジン名+バージョンで指定する(mysql8.0など)

  dynamic "parameter" {
    for_each = var.parameters
    content {
      name         = parameter.key
      value        = parameter.value
      apply_method = "pending-reboot" # static パラメータは 即時変更ができないため
    }
  }
  tags = { Name = var.rds_conf.name }
}