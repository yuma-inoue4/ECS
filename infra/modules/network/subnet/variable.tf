#--------------------------------
# tags
#--------------------------------
variable "name" { type = string }

#--------------------------------
# subnet
#--------------------------------
variable "vpc_id" {
  type = string
}
variable "subnets" {
  type = map(object({
    cidr_block              = string
    availability_zone       = string
    map_public_ip_on_launch = bool
  }))
}