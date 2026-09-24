resource "aws_security_group" "rds" {
  name        = "notesy-rds-sg"
  description = "Security group for Notesy PostgreSQL"
  vpc_id      = aws_vpc.notesy.id

  tags = {
    Name    = "notesy-rds-sg"
    Project = "notesy-app"
  }
}

resource "aws_db_subnet_group" "notesy" {
  name       = "notesy-db-subnet-group"
  subnet_ids = aws_subnet.private[*].id

  tags = {
    Name    = "notesy-db-subnet-group"
    Project = "notesy-app"
  }
}

resource "aws_vpc_security_group_ingress_rule" "rds_from_ecs" {
  security_group_id            = aws_security_group.rds.id
  referenced_security_group_id = aws_security_group.ecs.id
  from_port                    = 5432
  to_port                      = 5432
  ip_protocol                  = "tcp"
  description                  = "PostgreSQL access from ECS tasks"
}

resource "aws_db_instance" "notesy" {
  identifier = "notesy-postgres"

  engine         = "postgres"
  engine_version = "16"

  instance_class        = "db.t3.micro"
  allocated_storage     = 20
  max_allocated_storage = 50
  storage_type          = "gp3"
  storage_encrypted     = true

  db_name  = "notesy"
  username = var.db_username
  password = var.db_password
  port     = 5432

  db_subnet_group_name   = aws_db_subnet_group.notesy.name
  vpc_security_group_ids = [aws_security_group.rds.id]
  publicly_accessible    = false

  backup_retention_period = 7
  backup_window           = "03:00-04:00"
  maintenance_window      = "sun:04:00-sun:05:00"

  multi_az            = false
  deletion_protection = false
  skip_final_snapshot = true

  tags = {
    Name    = "notesy-postgres"
    Project = "notesy-app"
  }
}
