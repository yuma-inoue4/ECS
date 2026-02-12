#--------------------------------
# local vars
#--------------------------------
locals { # vpc_endpointで使用
  type_interface = "Interface"
  type_gateway   = "Gateway"
  service_prefix = "com.amazonaws"
}

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
  default = "ecs-practice"
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

#--------------------------------
# elb
#--------------------------------
variable "internal" { type = bool }
variable "load_balancer_type" { type = string }
variable "enable_deletion_protection" { type = bool }
variable "enable_http2" { type = bool }

#--------------------------------
# target_group
#--------------------------------
### target_group ###
variable "port" { type = number }
variable "protocol" { type = string }
variable "target_type" { type = string }

### health_check ###
variable "path" { type = string }
variable "interval" { type = number }
variable "timeout" { type = number }
variable "healthy_threshold" { type = number }
variable "unhealthy_threshold" { type = number }
variable "matcher" { type = string }
variable "hc_port" { type = string }
variable "hc_protocol" { type = string }

#--------------------------------
# listener
#--------------------------------
### listener ###
variable "listener_port" { type = number }
variable "listener_protocol" { type = string }

### default_action ###
variable "listener_type" { type = string }

#--------------------------------
# mysql
#--------------------------------
variable "mysql_host" { type = string }
variable "mysql_database" { type = string }
variable "mysql_username" { type = string }
variable "mysql_ssl" { type = string }
variable "mysql_password" {
  type      = string
  sensitive = true # planなどで非出力
}

#------------------------------
# ECS
#------------------------------
variable "retention_in_days" {
  description = "ログの保存期間(デフォルトは無期限)"
  type        = number
}

### cluster ###
# variable "cluster_name" { type = string }
variable "container_insights" { type = string }

### task definition ###
variable "network_mode" { type = string }
variable "requires_compatibilities" { type = list(string) }
variable "cpu" { type = number }
variable "memory" { type = number }
variable "container_port" { type = number }

### service ###
variable "desired_count" {
  description = "【重要】常に稼働させるコンテナの数"
  type        = number
}
variable "launch_type" {
  description = "マシンの起動タイプ"
  type        = string
}
variable "assign_public_ip" {
  description = "ブリックIPが必要か否か、Public Subnet なら true"
  type        = bool
}

#------------------------------
# task definition
#------------------------------
# logConfiguration(ログの出力先)は、mainにハードコード

variable "task" {
  description = "タスク定義"
  type = object({

    # foundation
    family                   = string
    requires_compatibilities = list(string) # 起動モード
    network_mode             = string       # NWモード(Fargateならawsvpc)
    cpu                      = number
    memory                   = number

    # os / cpu
    runtime_platform = object({
      operating_system_family = string # 使用するOS(FargateはLinuxを指定)
      cpu_architecture        = string # 使用するCPU(M系CPUのMCはARM64を指定)
    })

    # container_config
    container_name = string # コンテナ名
    container_port = number # コンテナポート(Fargateの場合は、hostと揃える)
    image_uri      = string
    essential      = bool   # 停止フラグ(Tのコンテナが止まるとタスク全体が停止する)
    protocol       = string # 使用プロトコル(tcp)
  })
}

variable "db_config" {
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