# 現在のASWリージョン情報を取得する
data "aws_region" "current" {}

#-------------------------------
# s3 bucket
#-------------------------------
resource "aws_s3_bucket" "remote_backend" {
  for_each = toset(var.rb_environment)

  bucket = "${var.project}-${var.bucket_suffix}-${each.key}"

  lifecycle { prevent_destroy = false }

  tags = {
    Name        = "${var.project}-${var.bucket_suffix}-${each.key}"
    environment = "${each.key}"
  }
}

#-------------------------------
# s3 bucket versionning
#-------------------------------
resource "aws_s3_bucket_versioning" "rb_versioning" {
  for_each = toset(var.rb_environment)

  bucket = aws_s3_bucket.remote_backend[each.key].id

  versioning_configuration {
    status = "Enabled"
  }
}

#------------------------------
# s3_bucket_encryption
#------------------------------
resource "aws_s3_bucket_server_side_encryption_configuration" "rb_encryption" {
  for_each = toset(var.rb_environment)
  bucket   = aws_s3_bucket.remote_backend[each.key].id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

#------------------------------
# s3_bucket_access_block
#------------------------------
resource "aws_s3_bucket_public_access_block" "rb_accessblock" {
  for_each = toset(var.rb_environment)
  bucket   = aws_s3_bucket.remote_backend[each.key].id

  block_public_acls       = true # 新規のパブリックACL作成を禁止
  block_public_policy     = true # 新規のパブリックバケットポリシーの適用を禁止
  ignore_public_acls      = true # 既存のパブリックACLを無視
  restrict_public_buckets = true # 既存のパブリックバケットポリシーを無視
}

#------------------------------
# s3_bucket_policy
#------------------------------
resource "aws_s3_bucket_policy" "rb_policy" {
  for_each = toset(var.rb_environment)
  bucket   = aws_s3_bucket.remote_backend[each.key].id

  # public_access_block 作成後に本リソースを作成する
  depends_on = [aws_s3_bucket_public_access_block.rb_accessblock]

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      # 1. バケットの削除を禁止
      {
        Sid       = "DenyDeleteBucket"
        Effect    = "Deny"
        Principal = "*"
        Action    = "s3:DeleteBucket"
        Resource  = aws_s3_bucket.remote_backend[each.key].arn
      },
      # 2. HTTP（非SSL）通信の拒否
      {
        Sid       = "EnforceSecureTransport"
        Effect    = "Deny"
        Principal = "*"
        Action    = "s3:*"
        Resource = [
          aws_s3_bucket.remote_backend[each.key].arn,
          "${aws_s3_bucket.remote_backend[each.key].arn}/*",
        ]
        Condition = {
          Bool = {
            "aws:SecureTransport" = "false"
          }
        }
      }
    ]
  })
}