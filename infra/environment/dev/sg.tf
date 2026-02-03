# frontend, webapp, database, vpc_ep

#--------------------------------
# sg
#--------------------------------
# frontend_sg
module "frontend_sg" {
  source = "../../modules/network/sg"
  name   = "${var.project}-${var.environment}-frontend_sg"
  vpc_id = module.vpc.vpc_id
  sgs    = var.frontend_sg
}

# frontend_sg
module "webapp_sg" {
  source = "../../modules/network/sg"
  name   = "${var.project}-${var.environment}-webapp_sg"
  vpc_id = module.vpc.vpc_id
  sgs    = var.webapp_sg
}

# database_sg
module "database_sg" {
  source = "../../modules/network/sg"
  name   = "${var.project}-${var.environment}-database_sg"
  vpc_id = module.vpc.vpc_id

  sgs = merge(var.database_sg, {
    "in_tcp_3306_from_webapp" = {
      type                     = "ingress"
      protocol                 = "tcp"
      from_port                = 3306
      to_port                  = 3306
      source_security_group_id = module.webapp_sg.security_group_id
    }
  })
}