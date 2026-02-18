#--------------------------------
# elb
#--------------------------------
variable "elb_core" {
  type = object({
    name                       = string
    load_balancer_type         = string
    internal                   = bool
    enable_deletion_protection = bool
    enable_http2               = bool
  })
}

variable "elb_nw" {
  type = object({
    security_groups = list(string)
    subnets         = list(string)
  })
}

#--------------------------------
# target group
#--------------------------------
### core
variable "tg_core" {
  type = object({
    name        = string
    target_type = string # TGに所属するインスタンスタイプ(ECS -> instance / Fargate -> ip)
    port        = number # TGが受け付けるポート(=コンテナのポート)
    protocol    = string # LB - TG間の通信プロトコル(通常はHTTP)
  })
}

### nw
variable "tg_nw" {
  type = object({
    vpc_id = string
  })
}

### health_check
variable "tg_hc" {
  description = "health checkの設定"
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
    name     = string
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