# Personal Finance Tracker

A full-stack web application for tracking personal income and expenses, built with Python Flask and deployed on AWS using modern DevOps practices.

---

## 📋 Table of Contents

- [Project Overview](#project-overview)
- [Features](#features)
- [Technology Stack](#technology-stack)
- [Project Architecture](#project-architecture)
- [Phase-wise Implementation](#phase-wise-implementation)
- [Local Development Setup](#local-development-setup)
- [AWS Deployment with Terraform](#aws-deployment-with-terraform)
- [API Endpoints](#api-endpoints)
- [Project Structure](#project-structure)
- [Troubleshooting](#troubleshooting)
- [Future Enhancements](#future-enhancements)
- [Contributing](#contributing)

---

## 🎯 Project Overview

This project serves as a **hands-on learning experience** for end-to-end application development, covering:

- Backend API development with Python Flask
- Database design and management (PostgreSQL)
- Containerization with Docker
- Infrastructure as Code (IaC) with Terraform
- Cloud deployment on AWS (EC2, RDS)
- CI/CD pipelines (planned)
- Container orchestration with Kubernetes (planned)

**Primary Goal:** Build a production-ready personal finance tracking application while learning modern DevOps practices.

---

## ✨ Features

### Current Features (Phase 3)
- ✅ User authentication (register/login)
- ✅ Add daily income and expenses
- ✅ Categorize transactions
- ✅ View all transactions
- ✅ RESTful API design
- ✅ PostgreSQL database integration
- ✅ Dockerized application
- ✅ AWS cloud deployment

### Planned Features
- 🔄 Monthly spend summaries
- 🔄 Category-wise analytics
- 🔄 Data visualization dashboard
- 🔄 Export transactions to CSV
- 🔄 Budget alerts and notifications

---

## 🛠 Technology Stack

| Layer | Technology | Purpose |
|-------|-----------|---------|
| **Backend** | Python 3.9, Flask | REST API development |
| **Database** | PostgreSQL 15.4 | Data persistence |
| **ORM** | SQLAlchemy | Database abstraction |
| **Containerization** | Docker, Docker Compose | Application packaging |
| **Infrastructure** | Terraform | Infrastructure as Code |
| **Cloud Platform** | AWS (EC2, RDS, VPC) | Application hosting |
| **Version Control** | Git, GitHub | Source code management |
| **Orchestration** | Kubernetes (EKS) - Planned | Container orchestration |
| **CI/CD** | Jenkins - Planned | Automated deployments |
| **Config Management** | Ansible - Planned | Server configuration |

---

## 🏗 Project Architecture

### High-Level Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                         User/Client                          │
└────────────────────────┬────────────────────────────────────┘
                         │ HTTP Requests
                         ↓
┌─────────────────────────────────────────────────────────────┐
│                    AWS EC2 Instance                          │
│  ┌──────────────────────────────────────────────────────┐   │
│  │           Docker Container                            │   │
│  │  ┌────────────────────────────────────────────────┐  │   │
│  │  │         Flask Application                      │  │   │
│  │  │  - REST API Endpoints                          │  │   │
│  │  │  - Business Logic                              │  │   │
│  │  │  - SQLAlchemy ORM                              │  │   │
│  │  └─────────────────┬──────────────────────────────┘  │   │
│  └────────────────────┼─────────────────────────────────┘   │
└───────────────────────┼─────────────────────────────────────┘
                        │ PostgreSQL Connection
                        ↓
┌─────────────────────────────────────────────────────────────┐
│              AWS RDS PostgreSQL Database                     │
│  - Tables: transactions                                      │
│  - Managed database service                                  │
│  - Automatic backups                                         │
└─────────────────────────────────────────────────────────────┘
```

### Network Architecture

```
AWS VPC (Default)
├── Security Group: personal-finance-sg
│   ├── Ingress: Port 22 (SSH)
│   ├── Ingress: Port 5000 (Flask API)
│   ├── Ingress: Port 5432 (PostgreSQL)
│   └── Egress: All traffic
│
├── EC2 Instance (t2.micro)
│   ├── AMI: Amazon Linux 2
│   ├── Public IP: Auto-assigned
│   └── Docker Container: Flask App
│
└── RDS Instance (db.t3.micro)
    ├── Engine: PostgreSQL 15.4
    ├── Storage: 20 GB
    └── Endpoint: Auto-generated
```

---

## 📦 Phase-wise Implementation

### ✅ Phase 1: Local Development (Completed)
- Set up Python virtual environment
- Develop Flask application with basic CRUD operations
- Implement SQLAlchemy models
- Test locally with SQLite

### ✅ Phase 2: Dockerization (Completed)
- Create Dockerfile for Flask application
- Write docker-compose.yml for local testing
- Implement database readiness check script
- Test containerized application locally

### ✅ Phase 3: Infrastructure Setup (Current Phase)
- Write Terraform configurations for AWS resources
- Provision EC2 instance for application hosting
- Set up RDS PostgreSQL database
- Configure security groups and networking
- Automate deployment via user_data script

### 🔄 Phase 4: Kubernetes Deployment (Planned)
- Deploy to local Kubernetes (minikube)
- Configure Kubernetes manifests (Deployments, Services)
- Deploy to AWS EKS cluster
- Implement horizontal pod autoscaling

### 🔄 Phase 5: CI/CD Pipeline (Planned)
- Set up Jenkins server
- Create pipeline for automated builds
- Implement automated testing
- Configure deployment stages

### 🔄 Phase 6: Configuration Management (Planned)
- Write Ansible playbooks for server configuration
- Automate application updates
- Optional: Integrate Kafka for event streaming

### 🔄 Phase 7: Frontend Development (Planned)
- Build responsive web UI with React/HTML/CSS
- Host frontend on S3 + CloudFront
- Integrate with backend API

---

## 💻 Local Development Setup

### Prerequisites

- Python 3.9+
- Git
- Docker & Docker Compose
- PostgreSQL (optional for local testing)

### Installation Steps

1. **Clone the repository**
   ```bash
   git clone https://github.com/Ritvik896/personal-finance-app.git
   cd personal-finance-app
   ```

2. **Create Python virtual environment**
   ```bash
   python -m venv venv
   source venv/bin/activate  # On Windows: venv\Scripts\activate
   ```

3. **Install dependencies**
   ```bash
   pip install -r backend/requirements.txt
   ```

4. **Set up environment variables**
   ```bash
   cp .env.example .env
   # Edit .env with your local PostgreSQL credentials
   ```

5. **Run with Docker Compose**
   ```bash
   docker-compose up --build
   ```

6. **Test the API**
   ```bash
   curl http://localhost:5000/
   # Expected: {"message":"Personal Finance Tracker API is running!"}
   ```

---

## ☁️ AWS Deployment with Terraform

### Prerequisites

- AWS Account with programmatic access
- AWS CLI configured (`aws configure`)
- Terraform installed (v1.0+)
- EC2 Key Pair created in AWS (ap-south-1 region)

### Deployment Steps

#### 1. Configure AWS Credentials

```bash
aws configure
# Enter:
# - AWS Access Key ID
# - AWS Secret Access Key
# - Default region: ap-south-1
# - Default output format: json
```

#### 2. Verify EC2 Key Pair

```bash
# Check if key pair exists
aws ec2 describe-key-pairs --key-names phase3-key --region ap-south-1

# If not exists, create it:
aws ec2 create-key-pair \
  --key-name phase3-key \
  --region ap-south-1 \
  --query 'KeyMaterial' \
  --output text > ~/.ssh/phase3-key.pem

chmod 400 ~/.ssh/phase3-key.pem
```

#### 3. Initialize Terraform

```bash
cd terraform/
terraform init
```

#### 4. Review Infrastructure Plan

```bash
terraform plan
# Review the resources that will be created:
# - Security Group
# - RDS PostgreSQL Instance
# - EC2 Instance
```

#### 5. Deploy Infrastructure

```bash
terraform apply
# Type 'yes' when prompted
# Wait 8-12 minutes for provisioning
```

#### 6. Get Deployment Outputs

```bash
terraform output
# Save the following:
# - ec2_public_ip: <IP_ADDRESS>
# - rds_endpoint: <RDS_ENDPOINT>
```

#### 7. Verify Deployment

```bash
# SSH into EC2 instance
ssh -i ~/.ssh/phase3-key.pem ec2-user@<EC2_PUBLIC_IP>

# Check Docker container
docker ps

# Check application logs
docker logs personal_finance_backend

# Exit SSH
exit
```

#### 8. Test Deployed API

```bash
# Set EC2 IP
export EC2_IP=<YOUR_EC2_PUBLIC_IP>

# Health check
curl http://$EC2_IP:5000/

# Get transactions
curl http://$EC2_IP:5000/transactions

# Add transaction
curl -X POST http://$EC2_IP:5000/transactions \
  -H "Content-Type: application/json" \
  -d '{
    "description": "Grocery Shopping",
    "amount": 150.50,
    "category": "Food",
    "date": "2025-10-23"
  }'
```

#### 9. Cleanup Resources

```bash
cd terraform/
terraform destroy
# Type 'yes' when prompted
```

---

## 🔌 API Endpoints

### Base URL
```
http://<EC2_PUBLIC_IP>:5000
```

### Endpoints

| Method | Endpoint | Description | Request Body |
|--------|----------|-------------|--------------|
| GET | `/` | Health check | - |
| GET | `/transactions` | Get all transactions | - |
| POST | `/transactions` | Add new transaction | JSON (see below) |

### Request/Response Examples

#### GET `/`
**Response:**
```json
{
  "message": "Personal Finance Tracker API is running!"
}
```

#### GET `/transactions`
**Response:**
```json
[
  {
    "id": 1,
    "description": "Grocery Shopping",
    "amount": 150.50,
    "category": "Food",
    "date": "2025-10-23"
  }
]
```

#### POST `/transactions`
**Request Body:**
```json
{
  "description": "Grocery Shopping",
  "amount": 150.50,
  "category": "Food",
  "date": "2025-10-23"
}
```

**Response:**
```json
{
  "message": "Transaction added successfully"
}
```

---

## 📁 Project Structure

```
personal-finance-app/
│
├── backend/
│   ├── app.py                 # Main Flask application
│   ├── config.py              # Database configuration
│   ├── requirements.txt       # Python dependencies
│   ├── wait-for-postgres.sh   # DB readiness check script
│   └── __init__.py            # Package initializer
│
├── terraform/
│   ├── main.tf                # Main infrastructure definition
│   ├── variables.tf           # Input variables
│   └── outputs.tf             # Output values
│
├── .env                       # Environment variables (not in git)
├── .env.example               # Example environment file
├── .gitignore                 # Git ignore rules
├── Dockerfile                 # Docker image definition
├── docker-compose.yml         # Docker Compose configuration
└── README.md                  # This file
```

---

## 🔧 Troubleshooting

### Common Issues and Solutions

#### 1. Terraform: "InvalidKeyPair.NotFound"

**Problem:** EC2 key pair doesn't exist in AWS.

**Solution:**
```bash
aws ec2 create-key-pair \
  --key-name phase3-key \
  --region ap-south-1 \
  --query 'KeyMaterial' \
  --output text > ~/.ssh/phase3-key.pem

chmod 400 ~/.ssh/phase3-key.pem
```

#### 2. SSH: "Permission denied (publickey)"

**Problem:** Incorrect key file permissions.

**Solution:**
```bash
chmod 400 ~/.ssh/phase3-key.pem
```

#### 3. Docker Container Not Running

**Problem:** User data script failed or Docker not started.

**Solution:**
```bash
# SSH to EC2
ssh -i ~/.ssh/phase3-key.pem ec2-user@<EC2_IP>

# Check user data logs
sudo cat /var/log/cloud-init-output.log

# Manually start Docker
sudo systemctl start docker
cd /home/ec2-user/app
sudo docker-compose up -d --build
```

#### 4. API Returns "Connection Refused"

**Problem:** Security group not allowing traffic or Flask not running.

**Solution:**
```bash
# Check security group in AWS Console
# Ensure port 5000 is open to 0.0.0.0/0

# SSH to EC2 and check Flask logs
docker logs personal_finance_backend
```

#### 5. Database Connection Timeout

**Problem:** RDS not ready or wrong endpoint.

**Solution:**
```bash
# Wait 2-3 minutes after terraform apply
# Check .env file on EC2 has correct RDS endpoint
cat /home/ec2-user/app/.env | grep POSTGRES_HOST
```

---

## 🚀 Future Enhancements

### Short-term Goals
- [ ] Add user authentication with JWT tokens
- [ ] Implement transaction update and delete endpoints
- [ ] Add date range filtering for transactions
- [ ] Create monthly summary endpoint
- [ ] Add category-wise expense breakdown

### Medium-term Goals
- [ ] Build React.js frontend
- [ ] Implement data visualization with charts
- [ ] Add budget setting and tracking
- [ ] Email notifications for budget alerts
- [ ] Export data to CSV/PDF

### Long-term Goals
- [ ] Multi-user support with role-based access
- [ ] Mobile application (React Native)
- [ ] Machine learning for expense prediction
- [ ] Integration with banking APIs
- [ ] Recurring transaction support

---

## 📝 Environment Variables

### Required Variables

| Variable | Description | Example |
|----------|-------------|---------|
| `POSTGRES_USER` | PostgreSQL username | `postgres` |
| `POSTGRES_PASSWORD` | PostgreSQL password | `your_password` |
| `POSTGRES_DB` | Database name | `postgres` |
| `POSTGRES_HOST` | Database host/endpoint | `localhost` or RDS endpoint |
| `POSTGRES_PORT` | Database port | `5432` |
| `FLASK_ENV` | Flask environment | `development` or `production` |

### Example .env File

```bash
POSTGRES_USER=postgres
POSTGRES_PASSWORD=your_secure_password
POSTGRES_DB=postgres
POSTGRES_HOST=localhost
POSTGRES_PORT=5432
FLASK_ENV=development
```

---

## 🤝 Contributing

This is a personal learning project, but suggestions and feedback are welcome!

### How to Contribute
1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

---

## 📄 License

This project is open source and available for educational purposes.

---

## 👤 Author

**Ritvik Kumar Sharma**

- GitHub: [@Ritvik896](https://github.com/Ritvik896)
- Project Link: [https://github.com/Ritvik896/personal-finance-app](https://github.com/Ritvik896/personal-finance-app)

---

## 🙏 Acknowledgments

- Flask documentation for excellent API examples
- AWS documentation for infrastructure guidance
- Terraform community for IaC best practices
- Docker documentation for containerization patterns

---

## 📊 Project Status

**Current Phase:** Phase 3 - Infrastructure Setup (Terraform Deployment) ✅

**Last Updated:** October 23, 2025

---

## 📞 Support

For issues, questions, or suggestions:
- Open an issue on GitHub
- Check the [Troubleshooting](#troubleshooting) section
- Review AWS CloudWatch logs for detailed error messages

---

**Happy Coding! 🚀**