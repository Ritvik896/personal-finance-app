output "rds_endpoint" {
  description = "RDS endpoint to use in the application"
  value       = aws_db_instance.postgres.address
}
