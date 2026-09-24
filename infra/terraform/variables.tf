variable "aws_region" {
  description = "AWS region for the Notesy infrastructure"
  type        = string
  default     = "us-east-1"
}

variable "db_username" {
  description = "RDS PostgreSQL master username"
  type        = string
  default     = "notesy"
}

variable "db_password" {
  description = "RDS PostgreSQL master password"
  type        = string
  sensitive   = true
}

variable "django_secret_key" {
  description = "Django secret key for the Notesy application"
  type        = string
  sensitive   = true
}
