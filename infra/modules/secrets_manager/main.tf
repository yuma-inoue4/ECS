#--------------------------------
# secrets manager
#--------------------------------
resource "aws_secretsmanager_secret" "main" {
  name                    = var.secret_name
  description             = var.description
  recovery_window_in_days = var.recovery_window_in_days
  tags                    = { Name = var.secret_name }
}

resource "aws_secretsmanager_secret_version" "main" {
  secret_id     = aws_secretsmanager_secret.main.id
  secret_string = jsonencode(var.secret_string)
}