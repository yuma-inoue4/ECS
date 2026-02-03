#--------------------------------
# tags
#--------------------------------
variable "name" { type = string }
variable "vpc_id" { type = string }

#--------------------------------
# SG
#--------------------------------
variable "sgs" {
  default = {}
  type = map(object({
    type                     = string
    from_port                = number
    to_port                  = number
    protocol                 = string
    cidr_blocks              = optional(list(string))
    source_security_group_id = optional(string)
  }))
}