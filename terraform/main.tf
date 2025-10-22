provider "aws" {
  region = var.region
}

# -------------------------------
# Security Group for EC2 + RDS
# -------------------------------
resource "aws_security_group" "app_sg" {
  name        = "personal-finance-sg"
  description = "Allow SSH, Flask, and Postgres"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # For testing only; restrict later
  }

  ingress {
    from_port   = 5000
    to_port     = 5000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # For testing only; restrict later
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# -------------------------------
# RDS PostgreSQL Instance
# -------------------------------
resource "aws_db_instance" "postgres" {
  identifier              = "personal-finance-db"
  engine                  = "postgres"
  engine_version          = "15.14"
  instance_class          = "db.t3.micro"
  allocated_storage       = 20
  db_name                 = var.db_name
  username                = var.db_username
  password                = var.db_password
  skip_final_snapshot     = true
  publicly_accessible     = true
  vpc_security_group_ids  = [aws_security_group.app_sg.id]
}

# -------------------------------
# EC2 Instance for Flask + Docker
# -------------------------------
resource "aws_instance" "flask" {
  ami                    = "ami-0b0ea68c435eb488d" # Amazon Linux 2 (Mumbai)
  instance_type          = "t2.micro"
  key_name               = var.key_name
  vpc_security_group_ids = [aws_security_group.app_sg.id]

  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              yum install -y docker git
              service docker start
              usermod -aG docker ec2-user

              # Clone the app
              git clone -b phase3-Terraform-Setup https://github.com/Ritvik896/personal-finance-app.git /home/ec2-user/app
              cd /home/ec2-user/app

              # Create .env dynamically from Terraform values
              cat <<EOT > .env
              POSTGRES_USER=${var.db_username}
              POSTGRES_PASSWORD=${var.db_password}
              POSTGRES_DB=${var.db_name}
              POSTGRES_HOST=${aws_db_instance.postgres.address}
              POSTGRES_PORT=5432
              EOT

              # Run the Dockerized Flask app
              docker-compose up -d --build
              EOF

  tags = {
    Name = "personal-finance-flask"
  }
}
