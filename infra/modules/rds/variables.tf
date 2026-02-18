#--------------------------------
# RDS
#--------------------------------
variable "rds_conf" {
  description = "RDSの設定"
  type = object({
    # エンジン
    name              = string # RDSの名前
    identifier        = string # RDSの識別子
    engine            = string # エンジンの種類
    engine_version    = string # エンジンのバージョン
    instance_class    = string # インスタンスのスペック
    allocated_storage = number # ストレージの容量
    storage_type      = string # ストレージのタイプ

    # 接続情報
    db_name  = string
    username = string
    password = string

    # ネットワーク
    vpc_security_group_ids = list(string)
    db_subnet_group_name   = string # RDSのサブネットグループ名
    parameter_group_name   = string # RDSのパラメータグループ名
    publicly_accessible    = bool   # RDSのパブリックアクセス許可

    # 冗長性
    skip_final_snapshot = bool # 最終スナップショットをスキップ
    deletion_protection = bool # 削除保護
    apply_immediately   = bool # 即時適用(パラメータ変更などを即時反映するか否か)
    multi_az            = bool # マルチAZ(trueで別AZにスタンバイが立ち上がる)
  })
}

#--------------------------------
# RDS / Subnet Group
#--------------------------------
variable "subnet_ids" {
  description = "RDSを配置するサブネットID"
  type        = list(string)
}

#--------------------------------
# RDS / Parameter group
#--------------------------------
variable "parameters" {
  description = "RDSのパラメータ"
  type        = map(string)
}