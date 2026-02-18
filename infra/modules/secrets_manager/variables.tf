#--------------------------------
# secrets manager
#--------------------------------
variable "secret_name" { type = string }
variable "description" { type = string }
variable "recovery_window_in_days" { type = number }
variable "secret_string" {
  description = "シークレットの内容（object/map）。モジュール内で jsonencode する。"
  type        = any
}
