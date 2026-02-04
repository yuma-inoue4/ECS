#--------------------------------
# tags
#--------------------------------
variable "project" {
  type    = string
  default = "ecs-practice"
}

variable "environment" {
  type    = string
  default = "dev"
}

# 現在のASWリージョン情報を取得する
data "aws_region" "current" {}

#--------------------------------
# vpc
#--------------------------------
variable "cidr_block" { type = string }

#--------------------------------
# subnets
#--------------------------------
### public ###
variable "public_subnets" {
  type = map(object({
    cidr_block              = string
    availability_zone       = string
    map_public_ip_on_launch = bool
  }))
}

### private ###
variable "private_subnets" {
  type = map(object({
    cidr_block              = string
    availability_zone       = string
    map_public_ip_on_launch = bool
  }))
}

#--------------------------------
# sg
#--------------------------------
### forntend_sg ###
variable "frontend_sg" {
  type = map(object({
    type                     = string
    from_port                = number
    to_port                  = number
    protocol                 = string
    cidr_blocks              = optional(list(string))
    source_security_group_id = optional(string)
  }))
}

### webapp_sg ###
variable "webapp_sg" {
  type = map(object({
    type                     = string
    from_port                = number
    to_port                  = number
    protocol                 = string
    cidr_blocks              = optional(list(string))
    source_security_group_id = optional(string)
  }))
}

### database_sg ###
variable "database_sg" {
  type = map(object({
    type                     = string
    from_port                = number
    to_port                  = number
    protocol                 = string
    cidr_blocks              = optional(list(string))
    source_security_group_id = optional(string)
  }))
}

### vpc_endpoint_sg ###
variable "vpc_endpoint_sg" {
  type = map(object({
    type                     = string
    from_port                = number
    to_port                  = number
    protocol                 = string
    cidr_blocks              = optional(list(string))
    source_security_group_id = optional(string)
  }))
}

#--------------------------------
# vpce
#--------------------------------
# (if型 -> sg & subnet) / (gw型 -> rt)
variable "s3_vpce" {
  default = {}
  type = map(object({
    vpc_endpoint_type   = string
    service_name        = optional(string)
    policy              = optional(string)
    security_group_ids  = optional(list(string))
    route_table_ids     = optional(list(string))
    subnet_ids          = optional(list(string))
    private_dns_enabled = optional(bool)
  }))
}

variable "ecr_dkr_vpce" {
  default = {}
  type = map(object({
    vpc_endpoint_type   = string
    service_name        = optional(string)
    policy              = optional(string)
    security_group_ids  = optional(list(string))
    route_table_ids     = optional(list(string))
    subnet_ids          = optional(list(string))
    private_dns_enabled = optional(bool)
  }))
}

variable "ecr_api" {
  default = {}
  type = map(object({
    vpc_endpoint_type   = string
    service_name        = optional(string)
    policy              = optional(string)
    security_group_ids  = optional(list(string))
    route_table_ids     = optional(list(string))
    subnet_ids          = optional(list(string))
    private_dns_enabled = optional(bool)
  }))
}

variable "cloudwatch" {
  default = {}
  type = map(object({
    vpc_endpoint_type   = string
    service_name        = optional(string)
    policy              = optional(string)
    security_group_ids  = optional(list(string))
    route_table_ids     = optional(list(string))
    subnet_ids          = optional(list(string))
    private_dns_enabled = optional(bool)
  }))
}

variable "ssm" {
  default = {}
  type = map(object({
    vpc_endpoint_type   = string
    service_name        = optional(string)
    policy              = optional(string)
    security_group_ids  = optional(list(string))
    route_table_ids     = optional(list(string))
    subnet_ids          = optional(list(string))
    private_dns_enabled = optional(bool)
  }))
}

variable "secretmanager" {
  default = {}
  type = map(object({
    vpc_endpoint_type   = string
    service_name        = optional(string)
    policy              = optional(string)
    security_group_ids  = optional(list(string))
    route_table_ids     = optional(list(string))
    subnet_ids          = optional(list(string))
    private_dns_enabled = optional(bool)
  }))
}

variable "ssmmessages" {
  default = {}
  type = map(object({
    vpc_endpoint_type   = string
    service_name        = optional(string)
    policy              = optional(string)
    security_group_ids  = optional(list(string))
    route_table_ids     = optional(list(string))
    subnet_ids          = optional(list(string))
    private_dns_enabled = optional(bool)
  }))
}