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
output "public_subnet_ids" {
  value = { for k, v in aws_subnet.public : k => v.id }
}

### private subnet ###
output "private_subnet_ids" {
  value = { for k, v in aws_subnet.private : k => v.id }
}

# subnetは、下記の通り map(object)で構成されている
# 
# variable "public_subnets" {
#   type = map(object({
#     cidr_block              = string
#     availability_zone       = string
#     map_public_ip_on_launch = bool
#   }))
# } 

# outputは、下記の通り map(string)出力されるが、このままでは使えない
# {
#   "private_subnet-1" = "subnet-0123456789abcdef0"
#   "private_subnet-2" = "subnet-0abcdef0123456789"
# }

# ここから、IDだけ取り出すには？ values関数を使う。
# values(module.network.private_subnet_ids)
# これで、以下のようなListになる
# [
#   "subnet-0123456789abcdef0",
#   "subnet-0abcdef0123456789"
# ]

# 備考:
# values(map) → map の値の list を返す
# keys(map) → map のキーの list を返す