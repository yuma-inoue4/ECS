resource "aws_ecr_repository" "main" {
  name                 = var.name
  image_tag_mutability = var.image_tag_mutability

  # プッシュされたタイミングで、自動的に脆弱性スキャンを開始
  image_scanning_configuration {
    scan_on_push = var.scan_on_push
  }

  lifecycle {
    prevent_destroy = var.prevent_destroy
  }
}