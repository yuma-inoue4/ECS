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

variable "task_conf" {
  description = "タスク定義"
  type = object({

    # task_definition
    cpu                      = number       # (H/W) CPU
    memory                   = number       # (H/W) メモリ
    network_mode             = string       # (NW) モード (Fargate -> awsvpc)
    requires_compatibilities = list(string) # (OP) 起動モード (Fargate -> FARGATE)

    # runtime_platform
    operating_system_family = string # OS (Fargate -> Linux)
    cpu_architecture        = string # (H/W) CPUアーキテクチャ (AppleシリコンMAC -> ARM64)

    # container_definitions
    name      = string # コンテナ名
    image_uri = string # コンテナイメージ
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

#------------------------------
# service
#------------------------------
variable "service_conf" {
  type = object({

    service_name  = string # サービス名
    desired_count = number # 稼働させるコンテナの数
    launch_type   = string # マシンの起動タイプ

    # network_configuration
    subnets          = list(string) # subnet
    security_groups  = list(string) # sg
    assign_public_ip = bool         # PublicIPが必要か

    # load_balancer
    target_group_arn = string # tg_group
    #container_name   = task_configで定義
    #container_port   = task_cofnigで定義
  })
}