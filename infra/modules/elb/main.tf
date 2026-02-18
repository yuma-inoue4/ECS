#------------------------------
# ELB
#------------------------------
# SGでアクセス制御する
# 2つ以上のAZのサブネットを指定して作成

resource "aws_lb" "main" {
  ### elb_core
  name                       = var.elb_core.name
  internal                   = var.elb_core.internal
  load_balancer_type         = var.elb_core.load_balancer_type
  enable_deletion_protection = var.elb_core.enable_deletion_protection
  enable_http2               = var.elb_core.enable_http2

  ### elb_nw
  security_groups = var.elb_nw.security_groups
  subnets         = var.elb_nw.subnets

  ### tags
  tags = { Name = var.elb_core.name }
}

#------------------------------
# target group
#------------------------------
resource "aws_lb_target_group" "main" {
  ### tg_core
  name        = var.tg_core.name
  port        = var.tg_core.port
  protocol    = var.tg_core.protocol
  target_type = var.tg_core.target_type

  ### tg_nw
  vpc_id = var.tg_nw.vpc_id

  ### tg_hc
  health_check {
    path                = var.tg_hc.path
    interval            = var.tg_hc.interval
    timeout             = var.tg_hc.timeout
    healthy_threshold   = var.tg_hc.healthy_threshold
    unhealthy_threshold = var.tg_hc.unhealthy_threshold
    matcher             = var.tg_hc.matcher
    port                = var.tg_hc.port
    protocol            = var.tg_hc.protocol
  }

  ### tags
  tags = { Name = var.tg_core.name }
}

#------------------------------
# listener
#------------------------------
resource "aws_lb_listener" "main" {

  ### listener_core
  load_balancer_arn = aws_lb.main.arn
  port              = var.listener_core.port
  protocol          = var.listener_core.protocol

  ### default_action
  default_action {
    target_group_arn = aws_lb_target_group.main.arn
    type             = var.listener_da.type
  }

  ### tags
  tags = { Name = var.listener_core.name }
}