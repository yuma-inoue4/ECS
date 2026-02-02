#--------------------------------
# tags
#--------------------------------
variable "name" {
  description = "tags in resource name"
  type        = string
}

#--------------------------------
# network
#--------------------------------
# vpc
variable "cidr_block" {
  type = string
}

variable "instance_tenancy" {
  type        = string
  description = "EC2作成時に物理サーバを占有するか否か"
  default     = "default"
}