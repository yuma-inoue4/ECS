#--------------------------------
# tags
#--------------------------------
variable "name" { type = string }

#--------------------------------
# route_table
#--------------------------------
variable "vpc_id" { type = string }
variable "subnet_ids" { type = map(string) }

variable "routes" {
  description = "デフォルトは空(pri/pub両対応のため)"
  default     = {}

  type = map(object({
    cidr_block           = string
    network_interface_id = optional(string)
    gateway_id           = optional(string)
  }))
}