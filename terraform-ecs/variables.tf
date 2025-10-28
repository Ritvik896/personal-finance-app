variable "region" {
  description = "AWS region"
  type        = string
  default     = "ap-south-1"
}

variable "project_name" {
  description = "Project name for resource naming"
  type        = string
  default     = "personal-finance"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "dev"
}

# Database Configuration
variable "db_username" {
  description = "PostgreSQL database username"
  type        = string
  default     = "postgres"
  sensitive   = true
}

variable "db_password" {
  description = "PostgreSQL database password"
  type        = string
  default     = "#Rks2751"
  sensitive   = true
}

variable "db_name" {
  description = "PostgreSQL database name"
  type        = string
  default     = "postgres"
}

# ECS Configuration
variable "ecs_task_cpu" {
  description = "CPU units for ECS task (256 = 0.25 vCPU)"
  type        = string
  default     = "256"
}

variable "ecs_task_memory" {
  description = "Memory for ECS task in MB"
  type        = string
  default     = "512"
}

variable "ecs_desired_count" {
  description = "Desired number of ECS tasks"
  type        = number
  default     = 1
}

variable "container_port" {
  description = "Port exposed by the container"
  type        = number
  default     = 5000
}

variable "health_check_path" {
  description = "Health check path for the application"
  type        = string
  default     = "/"
}

# Docker Image
variable "docker_image" {
  description = "Docker image for the application"
  type        = string
  default     = "public.ecr.aws/docker/library/python:3.9-slim"  # We'll build our own later
}

# Auto Scaling
variable "ecs_autoscale_min_capacity" {
  description = "Minimum number of ECS tasks"
  type        = number
  default     = 1
}

variable "ecs_autoscale_max_capacity" {
  description = "Maximum number of ECS tasks"
  type        = number
  default     = 4
}

variable "ecs_cpu_target_value" {
  description = "Target CPU utilization for auto scaling"
  type        = number
  default     = 70
}

variable "ecs_memory_target_value" {
  description = "Target memory utilization for auto scaling"
  type        = number
  default     = 80
}