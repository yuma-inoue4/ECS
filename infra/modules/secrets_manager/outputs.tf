# ECS の valueFrom 用: JSON キー参照の ARN（secret_arn:key:キー名::）
output "secret_arn" {
  value = aws_secretsmanager_secret.main.arn
}

# secret_string は AWS から JSON 文字列で返るため、jsondecode してからキー参照する
locals {
  secret = jsondecode(aws_secretsmanager_secret_version.main.secret_string)
}

output "username" {
  value     = local.secret["username"]
  sensitive = true
}

output "password" {
  value     = local.secret["password"]
  sensitive = true
}

output "database" {
  value = local.secret["database"]
}

output "hostname" {
  value = local.secret["hostname"]
}