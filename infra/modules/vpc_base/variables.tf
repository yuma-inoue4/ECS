#--------------------------------
# tags
#--------------------------------
variable "name" { type = string }

#--------------------------------
# VPC
#--------------------------------
variable "cidr_block" { type = string }

variable "instance_tenancy" {
  type        = string
  description = "EC2作成時に物理サーバを占有するか否か"
  default     = "default"
}

variable "enable_dns_support" {
  description = "VPC内のインスタンスがDNS解決できるか否か"
  default     = true
}

variable "enable_dns_hostnames" {
  description = "PublicIP付与されたインスタンスにドメインも付与するか否か"
  default     = true
}

#--------------------------------
# subnet
#--------------------------------
variable "public_subnets" {
  type = map(object({
    cidr_block              = string
    availability_zone       = string
    map_public_ip_on_launch = bool
  }))
}

variable "private_subnets" {
  type = map(object({
    cidr_block              = string
    availability_zone       = string
    map_public_ip_on_launch = bool
  }))
}

#--------------------------------
# route_table
#--------------------------------
variable "public_routes" {
  default = {}
  type = map(object({
    cidr_block           = string
    network_interface_id = optional(string)
    gateway_id           = optional(string)
  }))
}

variable "private_routes" {
  default = {}
  type = map(object({
    cidr_block           = string
    network_interface_id = optional(string)
    gateway_id           = optional(string)
  }))
}