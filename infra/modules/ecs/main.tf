#------------------------------
# var
#------------------------------
data "aws_region" "current" {}

#------------------------------
# iam policy
#------------------------------
# policy, role の中身・実態は, aws_iam_policy_document に記述
# 用意するは2つ (ECSタスク実行権限, SecretManagerアクセス権限)

resource "aws_iam_policy" "secretmanager_read" {
  description = "ECS -> SecretManager Access to fetch secrets"
  tags        = { Name = var.policy_name }
  name        = var.policy_name
  policy      = data.aws_iam_policy_document.secretmanager_read.json
}

data "aws_iam_policy_document" "secretmanager_read" {
  statement {
    effect = "Allow"
    actions = [
      "secretsmanager:GetSecretValue", # 値の取得
      "secretsmanager:DescribeSecret", # 値の読込み
      "kms:Decrypt"                    # 値の復号(KMSで暗号化されているため)
    ]
    resources = ["*"]
  }
}

#------------------------------
# iam role
#------------------------------
resource "aws_iam_role" "ecs_exec" {
  description        = "Assume role for ECS"
  tags               = { Name = var.role_name }
  name               = var.role_name
  assume_role_policy = data.aws_iam_policy_document.ecs_task_assume_role.json
}

data "aws_iam_policy_document" "ecs_task_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

#------------------------------
# role_policy attachment
#------------------------------
# 作成した IAMロール と IAMポリシー を紐付ける

### ecs secretmanager access ###
resource "aws_iam_role_policy_attachment" "ecs_secretmanager_access" {
  role       = aws_iam_role.ecs_exec.name
  policy_arn = aws_iam_policy.secretmanager_read.arn
}

### ecs task excution ### (こちらはマネージドロール)
resource "aws_iam_role_policy_attachment" "ecs_exec_task" {
  role       = aws_iam_role.ecs_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

#------------------------------
# Cloudwatch Log Group
#------------------------------
resource "aws_cloudwatch_log_group" "main" {
  tags              = { Name = var.log_name }
  name              = var.log_name
  retention_in_days = var.retention_in_days
}

#------------------------------
# ECS / Cluster
#------------------------------
resource "aws_ecs_cluster" "main" {
  name = var.cluster_name
  tags = { Name = var.cluster_name }

  # Cloudwatchにメトリクスを送信する機能
  setting {
    name  = "containerInsights"    # 固定(これしか指定できない)
    value = var.container_insights # enable or disabled
  }
}

#------------------------------
# ECS / Task Definition
#------------------------------
resource "aws_ecs_task_definition" "main" {
  execution_role_arn       = aws_iam_role.ecs_exec.arn
  family                   = var.family
  cpu                      = var.task_conf.cpu
  memory                   = var.task_conf.memory
  network_mode             = var.task_conf.network_mode
  requires_compatibilities = var.task_conf.requires_compatibilities

  runtime_platform {
    operating_system_family = var.task.platform.operating_system_family
    cpu_architecture        = var.task.platform.cpu_architecture
  }

  # コンテナ設定
  container_definitions = jsonencode([
    {
      name      = var.task_conf.name
      image     = var.task_conf.image_uri
      essential = var.task_conf.essential

      # ポートフォワーディング設定
      portMappings = [
        {
          containerPort = var.task_conf.port
          hostPort      = var.task_conf.port
          protocol      = var.task_conf.protocol
        }
      ]
      # 環境変数設定(DB)
      environment = [
        { name = "MYSQL_HOST", value = var.db_conf.host },
        { name = "MYSQL_USER", value = var.db_conf.username },
        { name = "MYSQL_PASSWORD", value = var.db_conf.password },
        { name = "MYSQL_DATABASE", value = var.db_conf.database },
        { name = "MYSQL_SSL", value = var.db_conf.ssl }
      ]

      # ログ設定(ログの出力先)
      logConfiguration = {
        logDriver = "awslogs" # awslogs -> Cloudwatch logsに出力
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.main.id
          "awslogs-region"        = data.aws_region.current.id
          "awslogs-stream-prefix" = "ecs"
        }
      }
    }
  ])
}

#------------------------------
# ECS / Service
#------------------------------
resource "aws_ecs_service" "main" {
  tags            = { Name = var.service_conf.service_name }
  cluster         = aws_ecs_cluster.main.arn
  task_definition = aws_ecs_task_definition.main.arn

  name          = var.service_conf.service_name
  desired_count = var.service_conf.desired_count
  launch_type   = var.service_conf.launch_type

  network_configuration {
    subnets          = var.service_conf.subnets
    security_groups  = var.service_conf.security_groups
    assign_public_ip = var.service_conf.assign_public_ip
  }

  load_balancer {
    target_group_arn = var.service_conf.target_group_arn
    container_name   = var.task_conf.name
    container_port   = var.task_conf.port
  }
}