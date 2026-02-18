#--------------------------------
# local vars
#--------------------------------
locals { # vpc_endpointで使用
  type_interface = "Interface"
  type_gateway   = "Gateway"
  service_prefix = "com.amazonaws"
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
      vpc_endpoint_type = local.type_gateway
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
      vpc_endpoint_type   = local.type_interface
      service_name        = "${local.service_prefix}.${data.aws_region.current.id}.ecr.dkr"
      security_group_ids  = [module.vpc_endpoint_sg.sg_ids]
      subnet_ids          = values(module.vpc_base.private_subnet_ids)
      private_dns_enabled = true
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
      vpc_endpoint_type   = local.type_interface
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
      vpc_endpoint_type   = local.type_interface
      service_name        = "${local.service_prefix}.${data.aws_region.current.id}.logs"
      security_group_ids  = [module.vpc_endpoint_sg.sg_ids]
      subnet_ids          = values(module.vpc_base.private_subnet_ids)
      private_dns_enabled = true
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
      vpc_endpoint_type   = local.type_interface
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
      vpc_endpoint_type   = local.type_interface
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
      vpc_endpoint_type   = local.type_interface
      service_name        = "${local.service_prefix}.${data.aws_region.current.id}.ssmmessages"
      security_group_ids  = [module.vpc_endpoint_sg.sg_ids]
      subnet_ids          = values(module.vpc_base.private_subnet_ids)
      private_dns_enabled = true
    }
  })
}