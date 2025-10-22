output "rds_endpoint" {
  description = "RDS endpoint to use in the application"
  value       = aws_db_instance.postgres.address
}

output "ec2_public_ip" {
  description = "Public IP of the EC2 instance running Flask app"
  value       = aws_instance.flask.public_ip
}
