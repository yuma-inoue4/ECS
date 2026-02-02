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
variable "public_subnets" {
  description = "public subnet name and cidr_block"
  type        = map(string)
}

variable "vpc_id" {
  type = string
}