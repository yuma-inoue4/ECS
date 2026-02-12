# memo: albは2つのパーツで構成される
# 1. ロードバランサー
# 2. リスナーグループ

# ロードバランサー
# SGでアクセス制御する
# 2つ以上のAZのサブネットを指定して作成

# リスナーグループ
# インスタンスやIPアドレスを指定できる

#------------------------------
# elb
#------------------------------
resource "aws_lb" "main" {
  tags                       = { Name = var.lb_name }
  name                       = var.lb_name
  security_groups            = var.security_groups
  subnets                    = var.subnets
  enable_deletion_protection = var.enable_deletion_protection

  # LBを外部に公開するか否か(false -> LBにパブリックIPを割り当てて公開する)
  internal = var.internal
  # LBのタイプ (application, network, gateway)
  load_balancer_type = var.load_balancer_type
  # HTTP2を有効にするか否か(Webサイトの表示速度が上がる)
  enable_http2 = var.enable_http2
}

#------------------------------
# target group
#------------------------------
resource "aws_lb_target_group" "ecs" {
  tags   = { Name = var.tg_name }
  name   = var.tg_name
  vpc_id = var.vpc_id

  # ターゲットが受け付けるポート(=コンテナのポート)
  port = var.port
  # LB - ターゲット間の通信プロトコル(通常はHTTP)
  protocol = var.protocol

  # ターゲットに所属するインスタンスタイプ(ECS -> instance / Fargate -> ip)
  # Fargate はインスタンスではなく、VPC内のIPアドレスを直接持つため
  target_type = var.target_type

  health_check {
    # 生存確認のためにアクセスするURLパス(/ や /health を指定する)
    path = var.path
    # 何秒おきに確認しに行くか
    interval = var.interval
    # レスポンスを待つ猶予秒
    timeout = var.timeout
    # 失敗したときに何回連続で成功したら「復活」とみなすか
    healthy_threshold = var.healthy_threshold
    # 正常時に何回連続で成功したら「失敗」とみなすか
    unhealthy_threshold = var.unhealthy_threshold
    # 正常とみなすHTTPステータスコード(通常は200)
    matcher = var.matcher
    # heath_check用
    port     = var.hc_port
    protocol = var.hc_protocol
  }
}

#------------------------------
# listener
#------------------------------
resource "aws_lb_listener" "http" {
  tags              = { Name = var.listener_name }
  load_balancer_arn = aws_lb.main.arn
  port              = var.listener_port
  protocol          = var.listener_protocol

  # どのリスナールールにも一致しなかった場合に実行されるデフォルトの動作
  # 個別のルールを設定していない場合、すべてのリクエストがここで処理される
  default_action {
    # 動作の種類 "forward"（ターゲットグループへ転送）を指定
    # 他には "redirect"（リダイレクト）や "fixed-response"（固定ページ表示）などがある
    type = var.listener_type

    # 転送先のターゲットグループ
    target_group_arn = aws_lb_target_group.ecs.arn
  }
}