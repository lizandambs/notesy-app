resource "aws_secretsmanager_secret" "notesy_secret" {
  name        = "notesy/app-secrets"
  description = "Secrets for the Notesy ECS application"

  tags = {
    Name    = "notesy-app-secrets"
    Project = "notesy-app"
  }
}

resource "aws_secretsmanager_secret_version" "notesy_secret" {
  secret_id = aws_secretsmanager_secret.notesy_secret.id

  secret_string = jsonencode({
    DJANGO_SECRET_KEY = var.django_secret_key
    DATABASE_URL      = "postgresql://${urlencode(var.db_username)}:${urlencode(var.db_password)}@${aws_db_instance.notesy.address}:5432/${aws_db_instance.notesy.db_name}"

  })
}

resource "aws_iam_role_policy" "ecs_secrets" {
  name = "notesy-ecs-secrets"
  role = aws_iam_role.ecs_execution.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "secretsmanager:GetSecretValue"
        ]
        Resource = aws_secretsmanager_secret.notesy_secret.arn
      }
    ]
  })
}

output "notesy_secret_arn" {
  value = aws_secretsmanager_secret.notesy_secret.arn
}
