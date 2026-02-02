#--------------------------------
# network 
#--------------------------------
# vpc
module "vpc" {
  source           = "../../modules/network/vpc"
  cidr_block       = var.cidr_block
  instance_tenancy = var.instance_tenancy
  name             = "${var.project}-${var.environment}-vpc"
}

# igw
module "igw" {
  source = "../../modules/network/igw"
  vpc_id = module.vpc.vpc_id
  name   = "${var.project}-${var.environment}-igw"
}

# subnet
# public subnet  [10.0.1.0/24, 10.0.2.0/24]
# private subnet [10.0.3.0/24, 10.0.4.0/24]
module "public_subnet" {
  source         = "../../modules/network/public_subnet"
  vpc_id         = module.vpc.vpc_id
  public_subnets = var.public_subnets
  name           = "${var.project}-${var.environment}-subnet"
}

module "private_subnet" {
  source          = "../../modules/network/private_subnet"
  vpc_id          = module.vpc.vpc_id
  private_subnets = var.private_subnets
  name            = "${var.project}-${var.environment}-subnet"
}