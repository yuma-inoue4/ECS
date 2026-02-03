#--------------------------------
# VPC
#--------------------------------
resource "aws_vpc" "main" {
  cidr_block           = var.cidr_block
  enable_dns_support   = var.enable_dns_support
  enable_dns_hostnames = var.enable_dns_hostnames
  instance_tenancy     = var.instance_tenancy
  tags                 = { Name = var.name }
}

#--------------------------------
# IGW
#--------------------------------
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
  tags   = { Name = var.name }
}

#--------------------------------
# subnet
#--------------------------------
resource "aws_subnet" "public" {
  vpc_id = aws_vpc.main.id

  # map(object)
  for_each                = var.public_subnets
  cidr_block              = each.value.cidr_block
  availability_zone       = each.value.availability_zone
  map_public_ip_on_launch = each.value.map_public_ip_on_launch
  tags                    = { Name = "${var.name}-${each.key}" }
}

resource "aws_subnet" "private" {
  vpc_id = aws_vpc.main.id

  # map(object)
  for_each                = var.private_subnets
  cidr_block              = each.value.cidr_block
  availability_zone       = each.value.availability_zone
  map_public_ip_on_launch = each.value.map_public_ip_on_launch
  tags                    = { Name = "${var.name}-${each.key}" }
}

#--------------------------------
# RT
#--------------------------------
### route table ###
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  tags   = { Name = var.name }
}
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id
  tags   = { Name = var.name }
}

### route table association ###
resource "aws_route_table_association" "public" {
  for_each       = aws_subnet.public
  subnet_id      = each.value.id
  route_table_id = aws_route_table.public.id
}
resource "aws_route_table_association" "private" {
  for_each       = aws_subnet.private
  subnet_id      = each.value.id
  route_table_id = aws_route_table.private.id
}

### route ###
resource "aws_route" "public" {
  route_table_id         = aws_route_table.public.id
  for_each               = var.public_routes
  destination_cidr_block = each.value.cidr_block
  network_interface_id   = each.value.network_interface_id
  gateway_id             = each.value.gateway_id
}
resource "aws_route" "public_igw" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.main.id
}

resource "aws_route" "private" {
  route_table_id         = aws_route_table.private.id
  for_each               = var.private_routes
  destination_cidr_block = each.value.cidr_block
  network_interface_id   = each.value.network_interface_id
  gateway_id             = each.value.gateway_id
}