#--------------------------------
# vpc_base
#--------------------------------
module "vpc_base" {
  source     = "../../modules/vpc_base"
  name       = "${var.project}-${var.environment}"
  cidr_block = var.cidr_block

  public_subnets  = var.public_subnets
  private_subnets = var.private_subnets
}

#--------------------------------
# ECR (Data Source)
#--------------------------------
data "aws_ecr_repository" "webapp" {
  name = "${var.project}-ecr-webapp" # bootで作成した名前を指定
}

#--------------------------------
# ELB
#--------------------------------
### frontend_alb ###
module "frontend" {
  source                     = "../../modules/alb"
  lb_name                    = "${var.project}-${var.environment}-alb-frontend"
  internal                   = var.internal
  load_balancer_type         = var.load_balancer_type
  security_groups            = [module.frontend_sg.sg_ids]
  subnets                    = values(module.vpc_base.public_subnet_ids)
  enable_deletion_protection = var.enable_deletion_protection
  enable_http2               = var.enable_http2

  ### target_group ###
  tg_name     = "${var.project}-${var.environment}-tg-frontend"
  vpc_id      = module.vpc_base.vpc_id
  port        = var.port
  protocol    = var.protocol
  target_type = var.target_type

  ### health_check ###
  path                = var.path
  interval            = var.interval
  timeout             = var.timeout
  healthy_threshold   = var.healthy_threshold
  unhealthy_threshold = var.unhealthy_threshold
  matcher             = var.matcher
  hc_port             = var.hc_port
  hc_protocol         = var.hc_protocol

  ### listener ###
  listener_name     = "${var.project}-${var.environment}-listener-frontend"
  listener_port     = var.listener_port
  listener_protocol = var.listener_protocol

  ### default_action ###
  listener_type = var.listener_type
}

#--------------------------------
# ECS
#--------------------------------
module "ecs_webapp" {
  source = "../../modules/ecs"

  ### policy and role ###
  policy_name       = "${var.project}-${var.environment}-ecs-exec-task-policy"
  role_name         = "${var.project}-${var.environment}-ecs-role"
  log_name          = "/ecs/${var.project}/${var.environment}/webapp"
  retention_in_days = var.retention_in_days

  ### cluster ###
  cluster_name       = "${var.project}-${var.environment}-ecs-cluster"
  container_insights = var.container_insights

  ### task definition ###
  family                   = "${var.project}-${var.environment}-ecs-webapp-task"
  cpu                      = var.cpu
  memory                   = var.memory
  network_mode             = var.network_mode
  requires_compatibilities = var.requires_compatibilities

  ### task definition -> container definition ###
  # container_name = "webapp"
  # container_port = var.container_port
  image_uri = "${data.aws_ecr_repository.webapp.repository_url}:latest"

  task      = var.task
  db_config = var.db_config

  ### service ###
  service_name     = "${var.project}-${var.environment}-ecs-webapp-service"
  desired_count    = var.desired_count
  launch_type      = var.launch_type
  assign_public_ip = var.assign_public_ip
  subnets          = values(module.vpc_base.private_subnet_ids)
  security_groups  = [module.webapp_sg.sg_ids]
  target_group_arn = module.frontend.tg_arn
}
