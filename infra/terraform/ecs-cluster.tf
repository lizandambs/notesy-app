resource "aws_ecs_cluster" "notesy" {
  name = "notesy-cluster"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }

  tags = {
    Name    = "notesy-cluster"
    Project = "notesy-app"
  }
}

resource "aws_cloudwatch_log_group" "notesy" {
  name              = "/ecs/notesy"
  retention_in_days = 7

  tags = {
    Name    = "notesy-ecs-logs"
    Project = "notesy-app"
  }
}

output "ecs_cluster_name" {
  value = aws_ecs_cluster.notesy.name
}
