#--------------------------------
# VPC
#--------------------------------
module "vpc" {
  source     = "../../modules/network/vpc"
  name       = "${var.project}-${var.environment}-vpc"
  cidr_block = var.cidr_block
}

#--------------------------------
# IGW
#--------------------------------
module "igw" {
  source = "../../modules/network/igw"
  name   = "${var.project}-${var.environment}-igw"
  vpc_id = module.vpc.vpc_id
}

#--------------------------------
# subnet
#--------------------------------
### private ###
module "private_subnet" {
  source  = "../../modules/network/subnet"
  name    = "${var.project}-${var.environment}-private_subnet"
  subnets = var.private_subnets
  vpc_id  = module.vpc.vpc_id
}

### public ###
module "public_subnet" {
  source  = "../../modules/network/subnet"
  name    = "${var.project}-${var.environment}-public_subnet"
  subnets = var.public_subnets
  vpc_id  = module.vpc.vpc_id
}

#--------------------------------
# route_table
#--------------------------------
### private ###
module "private_rt" {
  source     = "../../modules/network/rt"
  name       = "${var.project}-${var.environment}-private_rt"
  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.private_subnet.subnet_ids
  routes     = {}
}

### public ###
module "public_rt" {
  source     = "../../modules/network/rt"
  name       = "${var.project}-${var.environment}-public_rt"
  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.public_subnet.subnet_ids

  # route_igw
  routes = {
    "igw" = {
      cidr_block = "0.0.0.0/0"
      gateway_id = module.igw.igw_id
    }
  }
}