### vpc ###
output "vpc_id" {
  value = aws_vpc.main.id
}

### vpc ###
output "vpc_cidr" {
  value = aws_vpc.main.cidr_block
}

### igw ###
output "igw_id" {
  value = aws_internet_gateway.main.id
}

### route table ###
output "public_rt_ids" {
  value = aws_route_table.public.id
}

### route table ###
output "private_rt_ids" {
  value = aws_route_table.private.id
}

### public subnet ###
# subnetかつ値にidを指定した場合、以下のようなMapになる
# {
#   "private_subnet_1" = "subnet-0123456789abcdef0",
#   "private_subnet_2" = "subnet-0abcdef0123456789"
# }

# このMapから、value(=id)だけ取り出すには？
# Mapから指定した値だけを取出す values関数を使う。以下例
# values(module.network.private_subnet_ids)

output "public_subnet_ids" {
  value = { for k, v in aws_subnet.public : k => v.id }
}

### private subnet ###
output "private_subnet_ids" {
  value = { for k, v in aws_subnet.private : k => v.id }
}

