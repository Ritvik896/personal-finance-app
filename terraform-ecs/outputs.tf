# -------------------------------
# ECS Cluster Outputs
# -------------------------------
output "ecs_cluster_name" {
  description = "Name of the ECS cluster"
  value       = aws_ecs_cluster.main.name
}

output "ecs_cluster_arn" {
  description = "ARN of the ECS cluster"
  value       = aws_ecs_cluster.main.arn
}

# -------------------------------
# ECS Service Outputs
# -------------------------------
output "ecs_service_name" {
  description = "Name of the ECS service"
  value       = aws_ecs_service.app.name
}

output "ecs_task_definition_arn" {
  description = "ARN of the ECS task definition"
  value       = aws_ecs_task_definition.app.arn
}

# -------------------------------
# Load Balancer Outputs
# -------------------------------
output "alb_dns_name" {
  description = "DNS name of the Application Load Balancer"
  value       = aws_lb.app.dns_name
}

output "alb_url" {
  description = "URL of the Application Load Balancer"
  value       = "http://${aws_lb.app.dns_name}"
}

output "alb_arn" {
  description = "ARN of the Application Load Balancer"
  value       = aws_lb.app.arn
}

output "target_group_arn" {
  description = "ARN of the target group"
  value       = aws_lb_target_group.app.arn
}

# -------------------------------
# RDS Outputs
# -------------------------------
output "rds_endpoint" {
  description = "RDS database endpoint"
  value       = aws_db_instance.postgres.address
}

output "rds_port" {
  description = "RDS database port"
  value       = aws_db_instance.postgres.port
}

output "rds_database_name" {
  description = "RDS database name"
  value       = aws_db_instance.postgres.db_name
}

# -------------------------------
# CloudWatch Outputs
# -------------------------------
output "cloudwatch_log_group" {
  description = "CloudWatch log group for ECS"
  value       = aws_cloudwatch_log_group.ecs.name
}

# -------------------------------
# Quick Access Information
# -------------------------------
output "deployment_info" {
  description = "Deployment information"
  value = <<-EOT
  
  ============================================
  ECS Deployment Successful!
  ============================================
  
  Application URL: http://${aws_lb.app.dns_name}
  
  Test your API:
  - Health Check: curl http://${aws_lb.app.dns_name}/
  - Get Transactions: curl http://${aws_lb.app.dns_name}/transactions
  
  Monitoring:
  - ECS Cluster: ${aws_ecs_cluster.main.name}
  - CloudWatch Logs: ${aws_cloudwatch_log_group.ecs.name}
  
  Database:
  - RDS Endpoint: ${aws_db_instance.postgres.address}
  - Database Name: ${aws_db_instance.postgres.db_name}
  
  ============================================
  EOT
}