#--------------------------------
# data
#--------------------------------
# 現在のASWリージョン情報を取得する
data "aws_region" "current" {}

#--------------------------------
# tags
#--------------------------------
variable "project" {
  type    = string
  default = "ecs"
}

variable "environment" {
  type    = string
  default = "dev"
}

#--------------------------------
# vpc
#--------------------------------
variable "cidr_block" { type = string }

#--------------------------------
# subnets
#--------------------------------
### public ###
variable "public_subnets" {
  type = map(object({
    cidr_block              = string
    availability_zone       = string
    map_public_ip_on_launch = bool
  }))
}

### private ###
variable "private_subnets" {
  type = map(object({
    cidr_block              = string
    availability_zone       = string
    map_public_ip_on_launch = bool
  }))
}

#--------------------------------
# sg
#--------------------------------
### forntend_sg ###
variable "frontend_sg" {
  type = map(object({
    type                     = string
    from_port                = number
    to_port                  = number
    protocol                 = string
    cidr_blocks              = optional(list(string))
    source_security_group_id = optional(string)
  }))
}

### webapp_sg ###
variable "webapp_sg" {
  type = map(object({
    type                     = string
    from_port                = number
    to_port                  = number
    protocol                 = string
    cidr_blocks              = optional(list(string))
    source_security_group_id = optional(string)
  }))
}

### database_sg ###
variable "database_sg" {
  type = map(object({
    type                     = string
    from_port                = number
    to_port                  = number
    protocol                 = string
    cidr_blocks              = optional(list(string))
    source_security_group_id = optional(string)
  }))
}

### vpc_endpoint_sg ###
variable "vpc_endpoint_sg" {
  type = map(object({
    type                     = string
    from_port                = number
    to_port                  = number
    protocol                 = string
    cidr_blocks              = optional(list(string))
    source_security_group_id = optional(string)
  }))
}

#--------------------------------
# vpce
#--------------------------------
# (if型 -> sg & subnet) / (gw型 -> rt)
variable "s3_vpce" {
  default = {}
  type = map(object({
    vpc_endpoint_type   = string
    service_name        = optional(string)
    policy              = optional(string)
    security_group_ids  = optional(list(string))
    route_table_ids     = optional(list(string))
    subnet_ids          = optional(list(string))
    private_dns_enabled = optional(bool)
  }))
}

variable "ecr_dkr_vpce" {
  default = {}
  type = map(object({
    vpc_endpoint_type   = string
    service_name        = optional(string)
    policy              = optional(string)
    security_group_ids  = optional(list(string))
    route_table_ids     = optional(list(string))
    subnet_ids          = optional(list(string))
    private_dns_enabled = optional(bool)
  }))
}

variable "ecr_api" {
  default = {}
  type = map(object({
    vpc_endpoint_type   = string
    service_name        = optional(string)
    policy              = optional(string)
    security_group_ids  = optional(list(string))
    route_table_ids     = optional(list(string))
    subnet_ids          = optional(list(string))
    private_dns_enabled = optional(bool)
  }))
}

variable "cloudwatch" {
  default = {}
  type = map(object({
    vpc_endpoint_type   = string
    service_name        = optional(string)
    policy              = optional(string)
    security_group_ids  = optional(list(string))
    route_table_ids     = optional(list(string))
    subnet_ids          = optional(list(string))
    private_dns_enabled = optional(bool)
  }))
}

variable "ssm" {
  default = {}
  type = map(object({
    vpc_endpoint_type   = string
    service_name        = optional(string)
    policy              = optional(string)
    security_group_ids  = optional(list(string))
    route_table_ids     = optional(list(string))
    subnet_ids          = optional(list(string))
    private_dns_enabled = optional(bool)
  }))
}

variable "secretmanager" {
  default = {}
  type = map(object({
    vpc_endpoint_type   = string
    service_name        = optional(string)
    policy              = optional(string)
    security_group_ids  = optional(list(string))
    route_table_ids     = optional(list(string))
    subnet_ids          = optional(list(string))
    private_dns_enabled = optional(bool)
  }))
}

variable "ssmmessages" {
  default = {}
  type = map(object({
    vpc_endpoint_type   = string
    service_name        = optional(string)
    policy              = optional(string)
    security_group_ids  = optional(list(string))
    route_table_ids     = optional(list(string))
    subnet_ids          = optional(list(string))
    private_dns_enabled = optional(bool)
  }))
}

#--------------------------------
# ecr
#--------------------------------
variable "image_tag_mutability" { type = string }
variable "scan_on_push" { type = bool }
variable "force_delete" {
  type    = bool
  default = false
}

#----------------------------------------------------------------
# elb
#----------------------------------------------------------------
variable "elb_core" {
  type = object({
    name                       = optional(string)
    load_balancer_type         = string
    internal                   = bool
    enable_deletion_protection = bool
    enable_http2               = bool
  })
}

variable "elb_nw" {
  type = object({
    security_groups = optional(list(string))
    subnets         = optional(list(string))
  })
}

#--------------------------------
# elb / target group
#--------------------------------
variable "tg_core" {
  type = object({
    name        = optional(string)
    target_type = string # TGに所属するインスタンスタイプ(ECS -> instance / Fargate -> ip)
    port        = number # TGが受け付けるポート(=コンテナのポート)
    protocol    = string # LB - TG間の通信プロトコル(通常はHTTP)
  })
}

### nw
variable "tg_nw" {
  type = object({
    vpc_id = optional(string)
  })
}

### health_check
variable "tg_hc" {
  description = "Health Checkの設定"
  type = object({
    path                = string # 生存確認のためにアクセスするURLパス(/ や /health を指定)
    interval            = number # 何秒おきに確認しに行くか (デフォルトは30秒)
    timeout             = number # レスポンスを待つ猶予秒 (デフォルトは5秒)
    healthy_threshold   = number # 失敗したときに何回連続で成功したら「復活」とみなすか (デフォルトは2回)
    unhealthy_threshold = number # 正常時に何回連続で成功したら「失敗」とみなすか (デフォルトは2回)
    matcher             = string # 正常とみなすHTTPステータスコード (デフォルトは200)
    port                = string # heath_check用 (デフォルトはtraffic-port)
    protocol            = string # heath_check用 (デフォルトはHTTP)
  })
}

#--------------------------------
# elb / listener
#--------------------------------
### listener
variable "listener_core" {
  type = object({
    name     = optional(string)
    port     = number # 受け付けるポート
    protocol = string # 受け付けるプロトコル
  })
}

### default_action
variable "listener_da" {
  description = "default actionの設定"
  type = object({
    type = string # 動作の種類 "forward", "redirect", "fixed-response" など
  })
}

#----------------------------------------------------------------
# ecs
#----------------------------------------------------------------
variable "retention_in_days" {
  description = "ログの保存期間(デフォルトは無期限)"
  type        = number
}

#------------------------------
# ecs / clustr
#------------------------------
variable "container_insights" { type = string }


#------------------------------
# ecs / task definition
#------------------------------
# logConfiguration(ログの出力先)は、mainにハードコード
# familyは、var.projectと併せるため objectの外に定義

variable "task_conf" {
  description = "タスク定義"
  type = object({

    # task
    cpu                      = number       # (H/W) CPU
    memory                   = number       # (H/W) メモリ
    network_mode             = string       # (NW) モード (Fargate -> awsvpc)
    requires_compatibilities = list(string) # (OP) 起動モード (Fargate -> FARGATE)

    # runtime_platform
    operating_system_family = string # OS (Fargate -> Linux)
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
    host     = optional(string)
    database = string
    username = string
    password = string
    ssl      = string
  })
  sensitive = true # planに非出力(stateには記述される点に留意)
}

#------------------------------
# ecs / service
#------------------------------
variable "service_conf" {
  description = "サービス設定"
  type = object({
    desired_count    = number # 稼働させるコンテナの数
    launch_type      = string # マシンの起動タイプ
    assign_public_ip = bool   # PublicIPが必要か
  })
}

#------------------------------
# RDS
#------------------------------
variable "rds_conf" {
  description = "RDSの設定"
  type = object({
    # エンジン
    # name            = main.tf で注入
    # identifier      = main.tf で注入
    engine            = string
    engine_version    = string
    instance_class    = string
    allocated_storage = number
    storage_type      = string

    # 接続情報
    db_name  = string
    username = string
    password = string

    # ネットワーク
    # vpc_security_group_ids = main.tf で注入
    # db_subnet_group_name   = main.tf で注入
    # parameter_group_name   = main.tf で注入
    publicly_accessible = bool

    # 冗長性
    skip_final_snapshot = bool
    deletion_protection = bool
    apply_immediately   = bool
    multi_az            = bool
  })
}

variable "parameters" {
  description = "RDSのパラメータ"
  type        = map(string)
}

#--------------------------------
# secrets manager
#--------------------------------
variable "secret_name" {
  type    = string
  default = ""
}
variable "description" { type = string }             # 説明
variable "recovery_window_in_days" { type = number } # 復旧期間
variable "secret_string" {
  description = "Secrets Manager に格納する追加キー（username/password/database/hostname は main.tf で merge して注入）"
  type        = map(any)
  default     = {}
}
