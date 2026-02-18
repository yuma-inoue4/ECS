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

  ### Task definition ###
  family           = "${var.project}-${var.environment}-ecs-webapp-task"
  image_uri        = "${data.aws_ecr_repository.webapp.repository_url}:latest"
  task_conf        = var.task_conf
  db_conf          = local.db_conf_input
  mysql_secret_arn = module.secrets_manager.secret_arn

  ### Service ###
  service_name     = "${var.project}-${var.environment}-ecs-webapp-service"
  service_conf     = var.service_conf
  subnets          = values(module.vpc_base.private_subnet_ids)
  security_groups  = [module.webapp_sg.sg_ids]
  target_group_arn = module.frontend.tg_arn
}

locals {
  db_conf_input = merge(var.db_conf, {
    host = module.rds.address
  })
}

#------------------------------
# RDS
#------------------------------
module "rds" {
  source     = "../../modules/rds"
  rds_conf   = local.rds_module_input
  subnet_ids = values(module.vpc_base.private_subnet_ids)
  parameters = var.parameters
}

locals {
  rds_module_input = merge(var.rds_conf, {
    identifier             = "${var.project}-${var.environment}-mysql"
    name                   = "${var.project}-${var.environment}-mysql"
    vpc_security_group_ids = [module.database_sg.sg_ids]
    db_subnet_group_name   = "${var.project}-${var.environment}-rds-subnet-group"
    parameter_group_name   = "${var.project}-${var.environment}-mysql-params"
  })
}

#--------------------------------
# secrets manager
#--------------------------------
module "secrets_manager" {
  source                  = "../../modules/secrets_manager"
  secret_name             = "${var.project}-${var.environment}-mysql-secret"
  description             = var.description
  recovery_window_in_days = var.recovery_window_in_days
  secret_string = merge(var.secret_string, {
    username = var.db_conf.username
    password = var.db_conf.password
    database = var.db_conf.database
    hostname = module.rds.address
  })
}