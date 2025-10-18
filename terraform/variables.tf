variable "db_username" {
  default = "postgres"
}

variable "db_password" {
  default = "#Rks2751"
}

variable "db_name" {
  default = "postgres"
}

variable "key_name" {
  description = "Name of the EC2 key pair (must exist in AWS)"
  default     = "phase3-key"
}

variable "region" {
  default = "ap-south-1"  # Mumbai region for lower cost in India
}
