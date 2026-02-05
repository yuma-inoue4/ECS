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

#--------------------------------
# vpce
#--------------------------------
# (if型 -> sg & subnet) / (gw型 -> rt)

### S3 ###
module "s3_vpce" {
  source = "../../modules/vpce"
  name   = "${var.project}-${var.environment}-vpce-s3"
  vpc_id = module.vpc_base.vpc_id

  vpces = merge(var.s3_vpce, {
    "s3_vpce" = {
      vpc_endpoint_type = local.type_gw
      service_name      = "${local.service_prefix}.${data.aws_region.current.id}.s3"
      route_table_ids   = [module.vpc_base.private_rt_ids]
    }
  })
}

### ECR_Docker ###
module "ecr_dkr_vpce" {
  source = "../../modules/vpce"
  name   = "${var.project}-${var.environment}-ecr-dkr-vpce"
  vpc_id = module.vpc_base.vpc_id

  vpces = merge(var.ecr_dkr_vpce, {
    "ecr-dkr_vpce" = {
      vpc_endpoint_type  = local.type_if
      service_name       = "${local.service_prefix}.${data.aws_region.current.id}.ecr.dkr"
      security_group_ids = [module.vpc_endpoint_sg.sg_ids]
      subnet_ids         = values(module.vpc_base.private_subnet_ids)
    }
  })
}

### ECR_API ###
module "ecr_api" {
  source = "../../modules/vpce"
  name   = "${var.project}-${var.environment}-ecr-api-vpce"
  vpc_id = module.vpc_base.vpc_id

  vpces = merge(var.ecr_api, {
    "ecr-api_vpce" = {
      vpc_endpoint_type   = local.type_if
      service_name        = "${local.service_prefix}.${data.aws_region.current.id}.ecr.api"
      security_group_ids  = [module.vpc_endpoint_sg.sg_ids]
      subnet_ids          = values(module.vpc_base.private_subnet_ids)
      private_dns_enabled = true
    }
  })
}

### cloudwatch ###
module "cloudwatch" {
  source = "../../modules/vpce"
  name   = "${var.project}-${var.environment}-cloudwatch-vpce"
  vpc_id = module.vpc_base.vpc_id

  vpces = merge(var.cloudwatch, {
    "cloudwatch" = {
      vpc_endpoint_type  = local.type_if
      service_name       = "${local.service_prefix}.${data.aws_region.current.id}.logs"
      security_group_ids = [module.vpc_endpoint_sg.sg_ids]
      subnet_ids         = values(module.vpc_base.private_subnet_ids)
    }
  })
}

### ssm ###
module "ssm" {
  source = "../../modules/vpce"
  name   = "${var.project}-${var.environment}-ssm-vpce"
  vpc_id = module.vpc_base.vpc_id

  vpces = merge(var.ssm, {
    "ssm" = {
      vpc_endpoint_type   = local.type_if
      service_name        = "${local.service_prefix}.${data.aws_region.current.id}.ssm"
      security_group_ids  = [module.vpc_endpoint_sg.sg_ids]
      subnet_ids          = values(module.vpc_base.private_subnet_ids)
      private_dns_enabled = true
    }
  })
}

### secret_manager ###
module "secretmanager" {
  source = "../../modules/vpce"
  name   = "${var.project}-${var.environment}-secretmanager-vpce"
  vpc_id = module.vpc_base.vpc_id

  vpces = merge(var.secretmanager, {
    "secretmanager" = {
      vpc_endpoint_type   = local.type_if
      service_name        = "${local.service_prefix}.${data.aws_region.current.id}.secretsmanager"
      security_group_ids  = [module.vpc_endpoint_sg.sg_ids]
      subnet_ids          = values(module.vpc_base.private_subnet_ids)
      private_dns_enabled = true
    }
  })
}

### ssm_message's ###
module "ssmmessages" {
  source = "../../modules/vpce"
  name   = "${var.project}-${var.environment}-ssmmessages-vpce"
  vpc_id = module.vpc_base.vpc_id

  vpces = merge(var.ssmmessages, {
    "ssmmessages" = {
      vpc_endpoint_type   = local.type_if
      service_name        = "${local.service_prefix}.${data.aws_region.current.id}.ssmmessages"
      security_group_ids  = [module.vpc_endpoint_sg.sg_ids]
      subnet_ids          = values(module.vpc_base.private_subnet_ids)
      private_dns_enabled = true
    }
  })
}

#--------------------------------
# ecr
#--------------------------------
module "webapp" {
  source               = "../../modules/ecr"
  name                 = "${var.project}-${var.environment}-ecr-webapp"
  image_tag_mutability = var.image_tag_mutability
  scan_on_push         = var.scan_on_push
  force_delete         = var.force_delete
}