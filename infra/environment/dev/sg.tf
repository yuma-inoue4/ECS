#--------------------------------
# sg
#--------------------------------
### frontend_sg ###
module "frontend_sg" {
  source = "../../modules/sg"
  name   = "${var.project}-${var.environment}-frontend_sg"
  vpc_id = module.vpc_base.vpc_id
  sgs    = var.frontend_sg
}

#### webapp_sg ###
module "webapp_sg" {
  source = "../../modules/sg"
  name   = "${var.project}-${var.environment}-webapp_sg"
  vpc_id = module.vpc_base.vpc_id
  sgs    = var.webapp_sg
}

### database_sg ###
module "database_sg" {
  source = "../../modules/sg"
  name   = "${var.project}-${var.environment}-database_sg"
  vpc_id = module.vpc_base.vpc_id

  # webapp_sg からのtrafficを許可
  sgs = merge(var.database_sg, {
    "in_tcp_3306_from_webapp" = {
      type                     = "ingress"
      protocol                 = "tcp"
      from_port                = 3306
      to_port                  = 3306
      source_security_group_id = module.webapp_sg.sg_ids
    }
  })
}

### vpc_endpoint_sg ###
module "vpc_endpoint_sg" {
  source = "../../modules/sg"
  name   = "${var.project}-${var.environment}-vpc-endpoint-sg"
  vpc_id = module.vpc_base.vpc_id

  # vpc.main の cidr からのtrafficを許可
  sgs = merge(var.vpc_endpoint_sg, {
    "in_http_from_VPC.main_cidr" = {
      type        = "ingress"
      protocol    = "tcp"
      from_port   = 443
      to_port     = 443
      cidr_blocks = [module.vpc_base.vpc_cidr]
    }
  })
}