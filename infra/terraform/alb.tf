resource "aws_lb" "notesy" {
  name               = "notesy-alb"
  internal           = false
  load_balancer_type = "application"

  security_groups = [aws_security_group.alb.id]
  subnets         = aws_subnet.public[*].id

  tags = {
    Name    = "notesy-alb"
    Project = "notesy-app"
  }
}

resource "aws_lb_target_group" "notesy" {
  name        = "notesy-tg"
  port        = 8000
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = aws_vpc.notesy.id

  health_check {
    enabled             = true
    path                = "/"
    protocol            = "HTTP"
    port                = "traffic-port"
    healthy_threshold   = 2
    unhealthy_threshold = 3
    timeout             = 5
    interval            = 30
    matcher             = "200-399"
  }

  tags = {
    Name    = "notesy-tg"
    Project = "notesy-app"
  }
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.notesy.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.notesy.arn
  }
}

output "alb_dns_name" {
  value = aws_lb.notesy.dns_name
}
