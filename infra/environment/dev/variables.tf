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

#--------------------------------
# network
#--------------------------------
# vpc
variable "cidr_block" { type = string }
variable "instance_tenancy" {
  type        = string
  description = "EC2作成時に物理サーバを占有するか否か"
  default     = "default"
}

# subnet
variable "public_subnets" {
  type = map(string)
}

variable "private_subnets" {
  type = map(string)
}