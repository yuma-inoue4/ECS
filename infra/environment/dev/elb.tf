#--------------------------------
# locals
#--------------------------------
locals {
  description = "外部参照が必要な変数を入力"

  ### elb
  elb_core_input = merge(var.elb_core, {
    name = "${var.project}-${var.environment}-elb-frontend"
  })

  elb_nw_input = merge(var.elb_nw, {
    security_groups = [module.frontend_sg.sg_ids]
    subnets         = values(module.vpc_base.public_subnet_ids)
  })

  ### target_group
  tg_core_input = merge(var.tg_core, {
    name = "${var.project}-${var.environment}-elb-tg-frontend"
  })

  tg_nw_input = merge(var.tg_nw, {
    vpc_id = module.vpc_base.vpc_id
  })

  ### listener
  listener_core_input = merge(var.listener_core, {
    name = "${var.project}-${var.environment}-listener-frontend"
  })
}

#--------------------------------
# ELB
#--------------------------------
### frontend_alb ###
module "frontend" {
  source = "../../modules/elb"

  ### elb
  elb_core = local.elb_core_input
  elb_nw   = local.elb_nw_input

  ### target_group
  tg_core = local.tg_core_input
  tg_nw   = local.tg_nw_input
  tg_hc   = var.tg_hc # hc = health_check

  ### listener ###
  listener_core = local.listener_core_input
  listener_da   = var.listener_da # da = default_action
}