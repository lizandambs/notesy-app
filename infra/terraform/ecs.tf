resource "aws_security_group" "ecs" {
  name        = "notesy-ecs-sg"
  description = "Security group for Notesy ECS tasks"
  vpc_id      = aws_vpc.notesy.id

  egress {
    description = "Allow outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name    = "notesy-ecs-sg"
    Project = "notesy-app"
  }
}

resource "aws_security_group" "alb" {
  name        = "notesy-alb-sg"
  description = "Security group for Notesy Application Load Balancer"
  vpc_id      = aws_vpc.notesy.id

  ingress {
    description = "Allow HTTP from the internet"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name    = "notesy-alb-sg"
    Project = "notesy-app"
  }
}

resource "aws_vpc_security_group_ingress_rule" "ecs_from_alb" {
  security_group_id            = aws_security_group.ecs.id
  referenced_security_group_id = aws_security_group.alb.id

  from_port   = 8000
  to_port     = 8000
  ip_protocol = "tcp"

  description = "Allow HTTP traffic from ALB to ECS tasks"
}
