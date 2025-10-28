# Terraform ECS Deployment

Infrastructure as Code for deploying Personal Finance Tracker to AWS ECS (Elastic Container Service) with Fargate.

---

## 📁 Files

| File | Purpose |
|------|---------|
| `main.tf` | Provider configuration, VPC data sources, RDS, CloudWatch |
| `ecs.tf` | ECS cluster, task definition, service, IAM roles, auto-scaling |
| `alb.tf` | Application Load Balancer, target group, listener, security groups |
| `ecr.tf` | Amazon ECR repository for Docker images |
| `variables.tf` | Input variables for customization |
| `outputs.tf` | Output values after deployment |

---

## 🚀 Complete Deployment Guide

### **Prerequisites**

- AWS CLI configured (`aws configure`)
- Terraform installed (v1.0+)
- Docker installed and running
- AWS account with necessary permissions

---

### **Step 1: Deploy Infrastructure (Without Application)**

```bash
# Navigate to terraform-ecs directory
cd terraform-ecs/

# Initialize Terraform
terraform init

# Review what will be created
terraform plan

# Deploy infrastructure (will take 10-15 minutes)
terraform apply

# Type: yes
```

**What gets created:**
- ✅ ECS Cluster
- ✅ Application Load Balancer
- ✅ RDS PostgreSQL Database
- ✅ Security Groups
- ✅ IAM Roles
- ✅ CloudWatch Log Group
- ✅ ECR Repository

**Note:** At this point, ECS tasks will fail because we haven't pushed our Docker image yet. This is expected!

---

### **Step 2: Get ECR Repository URL**

```bash
# Get ECR repository URL
terraform output ecr_repository_url

# Save this URL - you'll need it!
# Example: 878740762729.dkr.ecr.ap-south-1.amazonaws.com/personal-finance-dev
```

---

### **Step 3: Build and Push Docker Image**

```bash
# Navigate to project root
cd ..

# Run build and push script
# Windows PowerShell:
.\scripts\build-and-push.ps1

# macOS/Linux:
chmod +x scripts/build-and-push.sh
./scripts/build-and-push.sh
```

**This script will:**
1. Authenticate Docker with ECR
2. Build Docker image from Dockerfile
3. Tag image for ECR
4. Push image to ECR repository

**⏱️ Wait Time:** 3-5 minutes

**Output will show:**
```
Build Complete!
Image URL: 878740762729.dkr.ecr.ap-south-1.amazonaws.com/personal-finance-dev:latest
```

---

### **Step 4: Update Terraform Variables with ECR Image**

**⚠️ IMPORTANT: Manual step required!**

Open `terraform-ecs/variables.tf` and find this section (around line 63):

```hcl
variable "docker_image" {
  description = "Docker image for the application"
  type        = string
  default     = "public.ecr.aws/docker/library/python:3.9-slim"  # ← CHANGE THIS
}
```

**Replace with your ECR image URL:**

```hcl
variable "docker_image" {
  description = "Docker image for the application"
  type        = string
  default     = "878740762729.dkr.ecr.ap-south-1.amazonaws.com/personal-finance-dev:latest"  # ← YOUR ECR URL
}
```

**Save the file.**

---

### **Step 5: Redeploy with Custom Docker Image**

```bash
# Navigate back to terraform-ecs
cd terraform-ecs/

# Apply changes to update task definition
terraform apply

# Type: yes
```

**This will:**
1. Create new task definition revision with your Docker image
2. Update ECS service to use new task definition
3. Perform rolling deployment (new tasks start, old tasks drain)

**⏱️ Wait Time:** 3-5 minutes

---

### **Step 6: Verify Deployment**

```bash
# Check service status
aws ecs describe-services \
  --cluster personal-finance-dev-cluster \
  --services personal-finance-dev-service \
  --region ap-south-1 \
  --query 'services[0].{Running:runningCount,Desired:desiredCount,Status:status}'

# Expected output:
# {
#   "Running": 1,
#   "Desired": 1,
#   "Status": "ACTIVE"
# }
```

```bash
# Check target health
aws elbv2 describe-target-health \
  --target-group-arn $(terraform output -raw target_group_arn) \
  --region ap-south-1

# Look for: "State": "healthy"
```

```bash
# View application logs
aws logs tail /ecs/personal-finance-dev --follow

# Look for:
# Postgres is up - executing command
# * Running on all addresses (0.0.0.0)
# * Running on http://127.0.0.1:5000
```

---

### **Step 7: Test Your Application**

```bash
# Get ALB URL
terraform output alb_url

# Test health endpoint
curl $(terraform output -raw alb_url)/

# Expected: {"message":"Personal Finance Tracker API is running!"}
```

```bash
# Test GET transactions
curl $(terraform output -raw alb_url)/transactions

# Expected: []
```

```bash
# Test POST transaction (PowerShell)
$ALB_URL = terraform output -raw alb_url
Invoke-RestMethod -Method POST -Uri "$ALB_URL/transactions" `
  -ContentType "application/json" `
  -Body '{"description":"ECS Deployment Test","amount":99.99,"category":"Testing","date":"2025-10-28"}'

# Test POST transaction (Linux/macOS)
curl -X POST $(terraform output -raw alb_url)/transactions \
  -H "Content-Type: application/json" \
  -d '{"description":"ECS Deployment Test","amount":99.99,"category":"Testing","date":"2025-10-28"}'

# Expected: {"message":"Transaction added successfully"}
```

```bash
# Verify transaction was saved
curl $(terraform output -raw alb_url)/transactions

# Expected: [{"amount":99.99,"category":"Testing",...}]
```

---

## 🔄 Update Application Code

When you make changes to your application code:

### **Step 1: Rebuild and Push Image**

```bash
# From project root
cd personal-finance-app/

# Run build script again
.\scripts\build-and-push.ps1  # Windows
./scripts/build-and-push.sh   # Linux/macOS
```

### **Step 2: Force New Deployment**

```bash
# Option A: Using AWS CLI (faster)
aws ecs update-service \
  --cluster personal-finance-dev-cluster \
  --service personal-finance-dev-service \
  --force-new-deployment \
  --region ap-south-1

# Option B: Using Terraform (creates new revision)
cd terraform-ecs/
terraform apply
```

ECS will perform a rolling update:
1. Start new tasks with updated image
2. Wait for health checks to pass
3. Drain old tasks
4. Complete deployment

---

## ⚙️ Configuration

### **Default Values**

```hcl
region                      = "ap-south-1"
project_name                = "personal-finance"
environment                 = "dev"
ecs_task_cpu               = "256"      # 0.25 vCPU
ecs_task_memory            = "512"      # 512 MB
ecs_desired_count          = 1          # Number of tasks
ecs_autoscale_min_capacity = 1
ecs_autoscale_max_capacity = 4
ecs_cpu_target_value       = 70         # Auto-scale at 70% CPU
ecs_memory_target_value    = 80         # Auto-scale at 80% memory
```

### **Customize Configuration**

Create `terraform.tfvars`:

```hcl
project_name                = "my-finance-app"
environment                 = "prod"
ecs_task_cpu               = "512"
ecs_task_memory            = "1024"
ecs_desired_count          = 2
ecs_autoscale_max_capacity = 10
```

---

## 📊 Resources Created

**Total: ~20 resources**

- **1x** ECS Cluster
- **1x** ECS Service
- **1x** ECS Task Definition
- **1x** Application Load Balancer
- **1x** ALB Listener (HTTP:80)
- **1x** Target Group
- **1x** ECR Repository
- **1x** RDS PostgreSQL (db.t3.micro)
- **3x** Security Groups (ALB, ECS Tasks, RDS)
- **2x** IAM Roles (Task Execution, Task Role)
- **2x** IAM Role Policy Attachments
- **1x** CloudWatch Log Group
- **2x** Auto Scaling Policies (CPU, Memory)
- **1x** Auto Scaling Target
- **1x** ECR Lifecycle Policy

---

## 💰 Cost Breakdown

**Monthly Estimated Cost (ap-south-1):**

| Resource | Type | Cost/Month |
|----------|------|------------|
| **ECS Fargate** | 0.25 vCPU, 0.5 GB RAM, 1 task | ~$13.00 |
| **RDS PostgreSQL** | db.t3.micro, 20 GB | ~$15.00 |
| **Application Load Balancer** | Active hours | ~$18.00 |
| **ECR Storage** | < 1 GB | ~$0.10 |
| **Data Transfer** | Minimal | ~$1.00 |
| **CloudWatch Logs** | 1 GB/month | ~$0.50 |
| **Total** | | **~$47.60/month** |

**Free Tier Benefits (First 12 months):**
- RDS db.t3.micro: 750 hours/month free
- Some data transfer free
- CloudWatch: 5 GB logs free

**Actual cost in first year:** ~$32/month (with free tier)

---

## 📊 Monitoring

### **CloudWatch Logs**

```bash
# View logs in real-time
aws logs tail /ecs/personal-finance-dev --follow

# View last 100 lines
aws logs tail /ecs/personal-finance-dev --since 30m
```

### **ECS Service Metrics**

Via AWS Console:
1. ECS → Clusters → `personal-finance-dev-cluster`
2. Services → `personal-finance-dev-service`
3. Metrics tab

Key metrics:
- CPU Utilization
- Memory Utilization
- Running task count
- Request count

### **Load Balancer Metrics**

```bash
# Check target health
aws elbv2 describe-target-health \
  --target-group-arn $(terraform output -raw target_group_arn)
```

---

## 🔧 Troubleshooting

### **Issue 1: Tasks Keep Failing**

```bash
# Check stopped tasks
aws ecs list-tasks \
  --cluster personal-finance-dev-cluster \
  --desired-status STOPPED \
  --region ap-south-1

# Get task details
aws ecs describe-tasks \
  --cluster personal-finance-dev-cluster \
  --tasks <TASK_ARN>
```

**Common causes:**
- Wrong Docker image URL in variables.tf
- Image doesn't exist in ECR
- Application crashes on startup
- Database connection fails

**Solution:** Check CloudWatch logs for error details

---

### **Issue 2: 503 Service Unavailable**

**Cause:** No healthy targets in target group

```bash
# Check target health
aws elbv2 describe-target-health \
  --target-group-arn $(terraform output -raw target_group_arn)
```

**Common reasons:**
- Tasks not passing health checks
- Health check path is incorrect
- Application not listening on port 5000
- Security group blocking traffic

---

### **Issue 3: Cannot Push to ECR**

```bash
# Re-authenticate with ECR
aws ecr get-login-password --region ap-south-1 | \
  docker login --username AWS --password-stdin \
  878740762729.dkr.ecr.ap-south-1.amazonaws.com
```

---

### **Issue 4: Terraform State Lock**

```bash
# If Terraform is locked
terraform force-unlock <LOCK_ID>

# Use with caution!
```

---

## 🧹 Cleanup

### **Option 1: Scale Down (Keep Infrastructure)**

```bash
# Stop all tasks but keep infrastructure
aws ecs update-service \
  --cluster personal-finance-dev-cluster \
  --service personal-finance-dev-service \
  --desired-count 0 \
  --region ap-south-1
```

**Saves compute costs but keeps:**
- Load balancer (~$18/month)
- RDS database (~$15/month)

---

### **Option 2: Destroy Everything**

```bash
cd terraform-ecs/

# Delete all resources
terraform destroy

# Type: yes

# ⏱️ Wait 10-15 minutes
```

**Deletes:**
- All ECS resources
- Load balancer
- RDS database (data is lost!)
- Security groups
- ECR repository (images deleted)
- CloudWatch logs
- IAM roles

**⚠️ WARNING:** Data in RDS will be permanently deleted!

---

## 📚 Key Learnings

**ECS Concepts:**
- Task Definitions (container blueprints)
- Services (manages tasks, load balancing)
- Clusters (logical grouping)
- Fargate (serverless compute)

**AWS Services Integration:**
- ECR for container registry
- ALB for load balancing
- RDS for database
- CloudWatch for logging
- IAM for permissions

**Deployment Workflow:**
1. Infrastructure provisioning (Terraform)
2. Image building (Docker)
3. Image storage (ECR)
4. Application deployment (ECS)
5. Monitoring (CloudWatch)

---

## 🔗 Related Documentation

- **Complete Deployment Guide:** `../docs/phase4a-ecs-deployment.md`
- **Phase 3 (EC2):** `../terraform/`
- **Phase 4B (Local Kubernetes):** `../kubernetes/local/`
- **Phase 4C (AWS EKS):** `../terraform-eks/`

---

## 📝 Notes for Phase 5 (CI/CD)

**Current Manual Steps (will be automated in Phase 5):**

1. ⚠️ Build and push Docker image
2. ⚠️ Update `docker_image` variable in variables.tf
3. ⚠️ Run `terraform apply`

**Phase 5 will automate:**
- ✅ Automatic build on code push (GitHub Actions / Jenkins)
- ✅ Automatic image push to ECR
- ✅ Automatic ECS deployment
- ✅ Automated testing
- ✅ Slack/Email notifications

---

## 🎯 Next Steps

**✅ Phase 4A Complete!**

**Next:** Phase 4B - Local Kubernetes
- Learn Kubernetes fundamentals
- Deploy to minikube/Docker Desktop
- No AWS costs while learning
- Prepare for Phase 4C (EKS)

📖 See: `../docs/phase4b-kubernetes-local.md`

---

## 💡 Quick Reference Commands

```bash
# Deploy infrastructure
terraform apply

# Build and push image
./scripts/build-and-push.sh

# Update task definition (after image push)
terraform apply

# Force new deployment
aws ecs update-service --cluster personal-finance-dev-cluster \
  --service personal-finance-dev-service --force-new-deployment

# View logs
aws logs tail /ecs/personal-finance-dev --follow

# Check target health
aws elbv2 describe-target-health --target-group-arn $(terraform output -raw target_group_arn)

# Scale tasks
aws ecs update-service --cluster personal-finance-dev-cluster \
  --service personal-finance-dev-service --desired-count 2

# Cleanup
terraform destroy
```

---

**Need help?** Check the comprehensive guide: `../docs/phase4a-ecs-deployment.md`

**Questions?** Review the troubleshooting section above or check CloudWatch logs.