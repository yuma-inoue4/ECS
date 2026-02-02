#--------------------------------
# tags
#--------------------------------
variable "name" {
  type = string
}

#--------------------------------
# network
#--------------------------------
# subnet
variable "private_subnets" {
  description = "private subnet name and cidr_block"
  type        = map(string)
}

variable "vpc_id" {
  type = string
}
