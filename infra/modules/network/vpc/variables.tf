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