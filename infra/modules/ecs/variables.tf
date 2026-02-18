#------------------------------
# ECS
#------------------------------
### policy and role / cloudwatch log ###
variable "policy_name" { type = string }
variable "role_name" { type = string }
variable "log_name" { type = string }

variable "retention_in_days" {
  description = "ログの保存期間(デフォルトは無期限)"
  type        = number
}

### cluster ###
variable "cluster_name" { type = string }
variable "container_insights" { type = string }

#------------------------------
# task definition
#------------------------------
# logConfiguration(ログの出力先)は、mainにハードコード
# familyは、var.projectと併せるため objectの外に定義

variable "family" {
  description = "タスク定義の名前"
  type        = string
}

variable "image_uri" {
  description = "コンテナイメージ"
  type        = string
}

variable "task_conf" {
  description = "タスク定義"
  type = object({

    # task
    cpu                      = number       # (H/W) CPU
    memory                   = number       # (H/W) メモリ
    network_mode             = string       # (NW) モード (Fargate -> awsvpc)
    requires_compatibilities = list(string) # (OP) 起動モード (Fargate -> FARGATE)

    # runtime_platform
    operating_system_family = string # OS (Fargate -> LINUX) ※大文字で指定
    cpu_architecture        = string # (H/W) CPUアーキテクチャ (AppleシリコンMAC -> ARM64)

    # container_definitions
    name      = string # コンテナ名
    essential = bool   # (OP) 停止フラグ(Trueのコンテナが止まるとタスク全体が停止)

    # port_mappings
    port     = number # (NW) ポート (Fargate -> hostと揃える)
    protocol = string # (NW) プロトコル (Fargate -> tcp)
  })
}

variable "db_conf" {
  description = "データベースの接続情報"
  type = object({
    host     = string
    database = string
    username = string
    password = string
    ssl      = string
  })
  sensitive = true # planに非出力(stateには記述される点に留意)
}

variable "mysql_secret_arn" {
  description = "Secrets Manager の MySQL 用シークレット ARN。ECS の valueFrom で参照する。"
  type        = string
}

#------------------------------
# service
#------------------------------
variable "service_conf" {
  description = "サービス設定"
  type = object({
    desired_count    = number # 稼働させるコンテナの数
    launch_type      = string # マシンの起動タイプ
    assign_public_ip = bool   # PublicIPが必要か
  })
}

variable "service_name" { type = string }          # サービス名
variable "subnets" { type = list(string) }         # サブネット
variable "security_groups" { type = list(string) } # セキュリティグループ
variable "target_group_arn" { type = string }      # ELBのターゲットグループARN