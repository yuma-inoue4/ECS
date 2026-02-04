variable "name" { type = string }
variable "vpc_id" { type = string }

variable "vpces" {
  default     = {}
  description = "(if型 -> sg & subnet) / (gw型 -> rt)"

  type = map(object({
    vpc_endpoint_type   = string
    service_name        = optional(string)
    policy              = optional(string)
    security_group_ids  = optional(list(string))
    subnet_ids          = optional(list(string))
    route_table_ids     = optional(list(string))
    private_dns_enabled = optional(bool)
  }))
}