resource "aws_ecs_service" "notesy" {
  name                   = "notesy-service"
  cluster                = aws_ecs_cluster.notesy.id
  task_definition        = aws_ecs_task_definition.notesy.arn
  desired_count          = 1
  launch_type            = "FARGATE"
  enable_execute_command = true

  network_configuration {
    subnets          = aws_subnet.private[*].id
    security_groups  = [aws_security_group.ecs.id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.notesy.arn
    container_name   = "notesy"
    container_port   = 8000
  }

  depends_on = [
    aws_lb_listener.http,
    aws_iam_role_policy.ecs_secrets
  ]

  tags = {
    Name    = "notesy-service"
    Project = "notesy-app"
  }
}
