output "vpc_id" {
  value = aws_vpc.notesy.id
}

output "public_subnet_ids" {
  value = aws_subnet.public[*].id
}

output "private_subnet_ids" {
  value = aws_subnet.private[*].id
}

output "availability_zones" {
  value = data.aws_availability_zones.available.names
}

output "rds_endpoint" {
  value = aws_db_instance.notesy.address
}

output "rds_port" {
  value = aws_db_instance.notesy.port
}

output "ecs_security_group_id" {
  value = aws_security_group.ecs.id
}

output "rds_security_group_id" {
  value = aws_security_group.rds.id
}

output "ecs_service_name" {
  description = "ECS service name for the Notesy application"
  value       = aws_ecs_service.notesy.name
}
