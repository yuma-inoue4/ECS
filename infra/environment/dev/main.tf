#--------------------------------
# network
#--------------------------------
module "network" {
  source     = "../../modules/network"
  name       = "${var.project}-${var.environment}"
  cidr_block = var.cidr_block

  public_subnets  = var.public_subnets
  private_subnets = var.private_subnets
}