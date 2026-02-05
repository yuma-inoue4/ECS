### vpc ###
output "vpc_id" {
  value = module.vpc_base.vpc_id
}

### vpc ###
output "vpc_cidr" {
  value = module.vpc_base.vpc_cidr
}

### igw ###
output "igw_id" {
  value = module.vpc_base.igw_id
}

### route table ###
output "public_rt_ids" {
  value = module.vpc_base.public_rt_ids
}

### route table ###
output "private_rt_ids" {
  value = module.vpc_base.private_rt_ids
}

### public subnet ###
# subnetかつ値にidを指定した場合、以下のようなMapになる
# {
#   "private_subnet_1" = "subnet-0123456789abcdef0",
#   "private_subnet_2" = "subnet-0abcdef0123456789"
# }

# このMapから、value(=id)だけ取り出すには？
# Mapから指定した値だけを取出す values関数を使う。以下例
# values(module.vpc_base.private_subnet_ids)

output "public_subnet_ids" {
  value = module.vpc_base.public_subnet_ids
}

### private subnet ###
output "private_subnet_ids" {
  value = module.vpc_base.private_subnet_ids
}
