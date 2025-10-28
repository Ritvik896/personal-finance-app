# Phase 4A: AWS ECS Deployment Guide

Complete guide for deploying the Personal Finance Tracker to AWS ECS (Elastic Container Service) with Fargate.

---

## 📋 Table of Contents

- [Overview](#overview)
- [Architecture](#architecture)
- [Prerequisites](#prerequisites)
- [ECS Concepts](#ecs-concepts)
- [Deployment Steps](#deployment-steps)
- [Testing](#testing)
- [Monitoring](#monitoring)
- [Cost Analysis](#cost-analysis)
- [Comparison with EC2](#comparison-with-ec2)
- [Troubleshooting](#troubleshooting)
- [Cleanup](#cleanup)

---

## 🎯 Overview

In this phase, we're deploying our Flask application to **AWS ECS Fargate** instead of managing EC2 instances directly. This provides:

- ✅ **No server management** - AWS manages the infrastructure
- ✅ **Auto-scaling** - Automatically scales based on CPU/memory
- ✅ **Load balancing** - Built-in Application Load Balancer
- ✅ **Better security** - Containers run in private subnets
- ✅ **Cost-effective** - Pay only for what you use

---

## 🏗 Architecture

```
Internet
   ↓
Application Load Balancer (ALB)
   ↓
ECS Service (Fargate)
   ├── Task 1 (Flask Container)
   ├── Task 2 (Flask Container) [Auto-scaled]
   └── Task N (Flask Container) [Auto-scaled]
   ↓
RDS PostgreSQL Database
```

### **Components:**

| Component | Purpose | Type |
|-----------|---------|------|
| **ALB** | Routes traffic to containers | Application Load Balancer |
| **ECS Cluster** | Logical grouping of services | ECS Cluster |
| **ECS Service** | Maintains desired number of tasks | ECS Service |
| **Task Definition** | Blueprint for containers | JSON template |
| **Fargate** | Serverless compute for containers | AWS Fargate |
| **RDS** | PostgreSQL database | db.t3.micro |

---

## 📋 Prerequisites

### **1. Complete Phase 3**
- ✅ EC2 deployment working
- ✅ Terraform basics understood
- ✅ AWS credentials configured

### **2. Install/Update Tools**

```bash
# Check AWS CLI version
aws --version
# Should be 2.x or higher

# Check Terraform version
terraform --version
# Should be 1.0 or higher

# Check Docker is running
docker --version
```

### **3. AWS Permissions**

Your IAM user needs these permissions:
- `AmazonECS_FullAccess`
- `AmazonRDSFullAccess`
- `ElasticLoadBalancingFullAccess`
- `IAMFullAccess` (for creating service roles)
- `AmazonVPCFullAccess`
- `CloudWatchLogsFullAccess`

---

## 📚 ECS Concepts (Learn Before Deploying)

### **1. ECS Cluster**
A logical grouping of tasks and services. Think of it as a "workspace" for your containers.

### **2. Task Definition**
A blueprint (JSON) that describes:
- Which Docker image to use
- CPU and memory requirements
- Environment variables
- Port mappings
- Log configuration

**Example:**
```json
{
  "family": "personal-finance-dev",
  "cpu": "256",
  "memory": "512",
  "containerDefinitions": [
    {
      "name": "personal-finance-container",
      "image": "your-image:latest",
      "portMappings": [{"containerPort": 5000}]
    }
  ]
}
```

### **3. ECS Service**
Manages running tasks:
- Maintains desired number of tasks
- Replaces failed tasks automatically
- Integrates with load balancer
- Handles rolling updates

### **4. Fargate vs EC2 Launch Type**

| Feature | **Fargate** (We're using this) | EC2 Launch Type |
|---------|-------------------------------|-----------------|
| Server Management | AWS manages | You manage EC2 instances |
| Cost | Pay per task | Pay for EC2 instances |
| Scaling | Automatic | Manual instance scaling |
| Best For | Simplicity, pay-as-you-go | Cost optimization, control |

### **5. Application Load Balancer (ALB)**
Routes HTTP/HTTPS traffic to containers:
- Health checks
- Path-based routing
- SSL termination (optional)
- Distributes load across tasks

---

## 🚀 Deployment Steps

### **Step 1: Deploy Infrastructure First**

First, we'll create all AWS resources WITHOUT a working application. This helps us understand what gets created.

```bash
cd terraform-ecs/

# Initialize Terraform
terraform init

# Expected output:
# Initializing the backend...
# Terraform has been successfully initialized!
```

```bash
# Validate configuration
terraform validate

# Expected: Success! The configuration is valid.
```

```bash
# Review what will be created
terraform plan

# Review carefully - should show ~20 resources to create
```

```bash
# Deploy infrastructure
terraform apply

# Type: yes

# ⏱️ Wait 10-15 minutes
```

**What gets created:**
- ✅ ECS Cluster
- ✅ Application Load Balancer
- ✅ RDS PostgreSQL
- ✅ Security Groups
- ✅ IAM Roles
- ✅ **ECR Repository** (for Docker images)
- ✅ CloudWatch Log Group
- ✅ Auto Scaling Policies

**Note:** ECS tasks will fail at this point - this is EXPECTED! We haven't pushed our Docker image yet.

---

### **Step 2: Get ECR Repository URL**

```bash
# Get ECR repository URL from Terraform outputs
terraform output ecr_repository_url

# Example output:
# 878740762729.dkr.ecr.ap-south-1.amazonaws.com/personal-finance-dev

# Save this URL - you'll need it in the next steps!
```

---

### **Step 3: Build and Push Docker Image to ECR**

Now we'll build our Flask application Docker image and push it to Amazon ECR.

#### **3.1: Run Build Script**

```bash
# Navigate to project root
cd ..  # Go back to personal-finance-app/

# Windows PowerShell:
.\scripts\build-and-push.ps1

# macOS/Linux:
chmod +x scripts/build-and-push.sh
./scripts/build-and-push.sh
```

**⏱️ Wait Time:** 3-5 minutes

**What the script does:**
1. Authenticates Docker with ECR
2. Builds Docker image from your Dockerfile
3. Tags image for ECR
4. Pushes image to ECR repository

**Expected output:**
```
=================================
Building and Pushing Docker Image
=================================
ECR Repository: 878740762729.dkr.ecr.ap-south-1.amazonaws.com/personal-finance-dev
Image Tag: latest

Step 1: Authenticating with ECR...
✓ Authentication successful

Step 2: Building Docker image...
✓ Image built successfully

Step 3: Tagging image for ECR...
✓ Image tagged successfully

Step 4: Pushing image to ECR...
✓ Image pushed successfully

=================================
Build Complete!
=================================
Image URL: 878740762729.dkr.ecr.ap-south-1.amazonaws.com/personal-finance-dev:latest
```

---

### **Step 4: Update Terraform Variables with ECR Image**

**⚠️ CRITICAL MANUAL STEP:**

You need to update the `docker_image` variable with your actual ECR image URL.

#### **4.1: Open terraform-ecs/variables.tf**

Find this section (around line 63):

```hcl
variable "docker_image" {
  description = "Docker image for the application"
  type        = string
  default     = "public.ecr.aws/docker/library/python:3.9-slim"  # ← OLD VALUE
}
```

#### **4.2: Replace with Your ECR Image URL**

```hcl
variable "docker_image" {
  description = "Docker image for the application"
  type        = string
  default     = "878740762729.dkr.ecr.ap-south-1.amazonaws.com/personal-finance-dev:latest"  # ← YOUR ECR URL
}
```

**Important:**
- Replace `878740762729` with your AWS account ID
- The URL should match what you got from `terraform output ecr_repository_url`
- Keep `:latest` at the end

#### **4.3: Save the File**

Make sure to save `variables.tf` after making the change!

---

### **Step 5: Redeploy with Custom Docker Image**

Now that we have our image in ECR and updated the variable, let's deploy the actual application:

```bash
# Navigate back to terraform-ecs
cd terraform-ecs/

# Apply changes
terraform apply

# Review changes - should show:
# - New task definition revision will be created
# - ECS service will be updated

# Type: yes
```

**⏱️ Wait Time:** 3-5 minutes

**What happens:**
1. Terraform creates new task definition revision with your ECR image
2. ECS service updated to use new task definition
3. ECS performs rolling deployment:
   - Starts new tasks with your Flask app
   - Waits for health checks to pass
   - Drains old (failing) tasks
   - Completes deployment

---

### **Step 6: Monitor Deployment Progress**

#### **6.1: Check Service Status**

```bash
# Check if tasks are running
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

Wait until `Running` equals `Desired`.

---

#### **6.2: Check Target Health**

```bash
# Check if load balancer sees healthy targets
aws elbv2 describe-target-health \
  --target-group-arn $(terraform output -raw target_group_arn) \
  --region ap-south-1

# Look for: "State": "healthy"
```

**Expected output:**
```json
{
  "TargetHealthDescriptions": [
    {
      "Target": {
        "Id": "10.0.x.x",
        "Port": 5000
      },
      "HealthCheckPort": "5000",
      "TargetHealth": {
        "State": "healthy"
      }
    }
  ]
}
```

---

#### **6.3: View Application Logs**

```bash
# Stream logs in real-time
aws logs tail /ecs/personal-finance-dev --follow

# Look for these key messages:
# ✓ Waiting for Postgres at personal-finance-dev-db...
# ✓ Postgres is up - executing command
# ✓ * Serving Flask app 'app'
# ✓ * Running on all addresses (0.0.0.0)
# ✓ * Running on http://127.0.0.1:5000
```

**Press Ctrl+C to stop following logs**

---

### **Step 7: Get Deployment Outputs**

```bash
terraform output
```

**You'll see:**
```
alb_url = "http://personal-finance-dev-alb-XXXXXXXXX.ap-south-1.elb.amazonaws.com"
ecs_cluster_name = "personal-finance-dev-cluster"
ecs_service_name = "personal-finance-dev-service"
rds_endpoint = "personal-finance-dev-db.xxxxx.ap-south-1.rds.amazonaws.com"
cloudwatch_log_group = "/ecs/personal-finance-dev"
```

**📝 Save the `alb_url` - you'll need it for testing!**

---

### **Step 8: Wait for Tasks to Start**

```bash
# Check service status
aws ecs describe-services \
  --cluster personal-finance-dev-cluster \
  --services personal-finance-dev-service \
  --region ap-south-1 \
  --query 'services[0].deployments[0].{Status:status,Running:runningCount,Desired:desiredCount}'
```

**Expected output:**
```json
{
  "Status": "PRIMARY",
  "Running": 1,
  "Desired": 1
}
```

**Wait until `Running` equals `Desired` (usually 2-3 minutes)**

---

### **Step 9: Check Task Health**

```bash
# Get task ID
aws ecs list-tasks \
  --cluster personal-finance-dev-cluster \
  --service-name personal-finance-dev-service \
  --region ap-south-1
```

```bash
# Check task logs (replace TASK_ID)
aws logs tail /ecs/personal-finance-dev --follow
```

**Look for:**
```
Postgres is up - executing command
 * Serving Flask app 'app'
 * Running on http://0.0.0.0:5000
```

---

## 🧪 Testing

### **Test 1: Health Check**

```bash
# Get ALB URL
ALB_URL=$(terraform output -raw alb_url)

# Test health endpoint
curl $ALB_URL/

# Expected:
# {"message":"Personal Finance Tracker API is running!"}
```

### **Test 2: Get All Transactions**

```bash
curl $ALB_URL/transactions

# Expected (empty initially):
# []
```

### **Test 3: Add a Transaction**

```bash
# Windows PowerShell
$ALB_URL = terraform output -raw alb_url
Invoke-RestMethod -Method POST -Uri "$ALB_URL/transactions" `
  -ContentType "application/json" `
  -Body '{"description":"ECS Test Transaction","amount":99.99,"category":"Testing","date":"2025-10-28"}'

# macOS/Linux
curl -X POST $ALB_URL/transactions \
  -H "Content-Type: application/json" \
  -d '{"description":"ECS Test Transaction","amount":99.99,"category":"Testing","date":"2025-10-28"}'

# Expected:
# {"message":"Transaction added successfully"}
```

### **Test 4: Verify Transaction**

```bash
curl $ALB_URL/transactions

# Expected:
# [{"amount":99.99,"category":"Testing","date":"2025-10-28","description":"ECS Test Transaction","id":1}]
```

### **Test 5: Browser Test**

Open your browser and visit:
```
http://personal-finance-dev-alb-XXXXXXXXX.ap-south-1.elb.amazonaws.com/transactions
```

---

## 📊 Monitoring

### **CloudWatch Logs**

```bash
# View logs in real-time
aws logs tail /ecs/personal-finance-dev --follow

# View last 100 lines
aws logs tail /ecs/personal-finance-dev --since 10m
```

**Or via AWS Console:**
1. Go to CloudWatch → Log groups
2. Find `/ecs/personal-finance-dev`
3. Click on log streams

---

### **ECS Service Metrics**

**Via AWS Console:**
1. Go to ECS → Clusters → `personal-finance-dev-cluster`
2. Click on service: `personal-finance-dev-service`
3. View "Metrics" tab

**Key Metrics:**
- CPU Utilization
- Memory Utilization
- Running tasks count
- Pending tasks count

---

### **Load Balancer Health**

```bash
# Check target health
aws elbv2 describe-target-health \
  --target-group-arn $(terraform output -raw target_group_arn) \
  --region ap-south-1
```

**Expected:**
```json
{
  "TargetHealthDescriptions": [
    {
      "Target": {
        "Id": "10.0.x.x",
        "Port": 5000
      },
      "HealthCheckPort": "5000",
      "TargetHealth": {
        "State": "healthy"
      }
    }
  ]
}
```

---

## 💰 Cost Analysis

### **Monthly Cost Breakdown (ap-south-1)**

| Resource | Specification | Cost/Month (Approx.) |
|----------|--------------|---------------------|
| **ECS Fargate** | 0.25 vCPU, 0.5 GB RAM | ~$13.00 |
| **RDS (db.t3.micro)** | 20 GB storage | ~$15.00 |
| **Application Load Balancer** | Active hours | ~$18.00 |
| **Data Transfer** | Minimal | ~$1.00 |
| **CloudWatch Logs** | 1 GB/month | ~$0.50 |
| **Total** | | **~$47.50/month** |

### **Cost Comparison**

| Deployment | Monthly Cost | Notes |
|------------|-------------|-------|
| **Phase 3 (EC2)** | ~$26 | Cheaper, more manual |
| **Phase 4A (ECS)** | ~$47.50 | More expensive, fully managed |
| **Phase 4C (EKS)** | ~$105 | Most expensive, Kubernetes |

### **Cost Optimization Tips**

1. **Use Free Tier (First Year)**
   - RDS: 750 hours/month free
   - Some data transfer free
   - CloudWatch: 5 GB logs free

2. **Stop When Not Using**
   ```bash
   # Update desired count to 0
   aws ecs update-service \
     --cluster personal-finance-dev-cluster \
     --service personal-finance-dev-service \
     --desired-count 0 \
     --region ap-south-1
   
   # Destroy everything when done testing
   terraform destroy
   ```

3. **Use Spot Instances (Advanced)**
   - Can save up to 70% on compute
   - Requires EC2 launch type instead of Fargate

---

## 📊 Comparison with EC2 (Phase 3)

| Feature | **Phase 3 (EC2)** | **Phase 4A (ECS Fargate)** |
|---------|-------------------|---------------------------|
| **Setup Complexity** | ⭐⭐⭐ Moderate | ⭐⭐⭐⭐ More complex |
| **Server Management** | Manual (SSH, docker-compose) | None - Fully managed |
| **Scaling** | Manual | Automatic (CPU/Memory based) |
| **Load Balancing** | None (single IP) | Built-in ALB |
| **High Availability** | Single AZ | Multi-AZ by default |
| **Deployment Speed** | ~10 minutes | ~15 minutes |
| **Cost** | ~$26/month | ~$47.50/month |
| **Monitoring** | Basic | CloudWatch + Container Insights |
| **Security** | Public EC2 | Private containers |
| **Updates** | SSH + manual restart | Rolling updates |
| **Best For** | Learning, dev environments | Production, scalable apps |

### **When to Use ECS:**
- ✅ Production applications
- ✅ Need auto-scaling
- ✅ Want managed infrastructure
- ✅ Multiple environments (dev, staging, prod)
- ✅ Team collaboration

### **When to Use EC2 (Phase 3):**
- ✅ Learning/development
- ✅ Tight budget
- ✅ Simple applications
- ✅ Need full server control
- ✅ One-time deployments

---

## 🔧 Troubleshooting

### **Issue 1: Tasks Not Starting**

**Symptom:**
```bash
aws ecs describe-services ...
# Shows: Running: 0, Desired: 1
```

**Diagnosis:**
```bash
# Check stopped tasks
aws ecs list-tasks \
  --cluster personal-finance-dev-cluster \
  --desired-status STOPPED \
  --region ap-south-1

# Get task details
aws ecs describe-tasks \
  --cluster personal-finance-dev-cluster \
  --tasks <TASK_ARN> \
  --region ap-south-1
```

**Common Causes:**
- ❌ Docker image doesn't exist or is invalid
- ❌ Insufficient IAM permissions
- ❌ Health check failing
- ❌ Container crashing immediately

**Solution:**
Check CloudWatch logs for errors:
```bash
aws logs tail /ecs/personal-finance-dev --since 30m
```

---

### **Issue 2: ALB Returns 503 Service Unavailable**

**Symptom:**
```bash
curl $ALB_URL/
# Returns: 503 Service Unavailable
```

**Cause:** No healthy targets in target group

**Solution:**
```bash
# Check target health
aws elbv2 describe-target-health \
  --target-group-arn $(terraform output -raw target_group_arn) \
  --region ap-south-1

# Look for TargetHealth.State = "unhealthy"
# Check TargetHealth.Reason for details
```

**Common Issues:**
- Health check path is wrong (default: `/`)
- Container not listening on port 5000
- Security group blocking traffic

---

### **Issue 3: Database Connection Timeout**

**Symptom:**
CloudWatch logs show:
```
Waiting for Postgres at <RDS_ENDPOINT>:5432...
Postgres is unavailable - sleeping
```

**Diagnosis:**
```bash
# Check RDS security group
aws ec2 describe-security-groups \
  --group-ids $(terraform output -raw rds_security_group_id) \
  --region ap-south-1
```

**Solution:**
- Verify RDS security group allows traffic from ECS tasks
- Check RDS is in "Available" state
- Wait 2-3 minutes for RDS to fully initialize

---

### **Issue 4: Cannot Access ALB URL**

**Symptom:**
```bash
curl $ALB_URL/
# Connection timeout or refused
```

**Diagnosis:**
```bash
# Check ALB state
aws elbv2 describe-load-balancers \
  --names personal-finance-dev-alb \
  --region ap-south-1 \
  --query 'LoadBalancers[0].State'
```

**Solution:**
- Wait 3-5 minutes after `terraform apply`
- ALB takes time to provision
- Check ALB security group allows inbound port 80

---

### **Issue 5: Auto Scaling Not Working**

**Symptom:**
High CPU but no new tasks created

**Diagnosis:**
```bash
# Check auto scaling target
aws application-autoscaling describe-scalable-targets \
  --service-namespace ecs \
  --region ap-south-1

# Check scaling activities
aws application-autoscaling describe-scaling-activities \
  --service-namespace ecs \
  --region ap-south-1
```

**Solution:**
- Verify auto scaling policies are created
- Check CloudWatch metrics for ECS service
- Ensure `ecs_autoscale_max_capacity` is > desired count

---

### **Issue 6: Task Keeps Restarting**

**Symptom:**
Task starts, then stops after a few seconds

**Diagnosis:**
```bash
# Check task exit code
aws ecs describe-tasks \
  --cluster personal-finance-dev-cluster \
  --tasks <TASK_ARN> \
  --region ap-south-1 \
  --query 'tasks[0].containers[0].{ExitCode:exitCode,Reason:reason}'
```

**Solution:**
- Check CloudWatch logs for Python errors
- Verify environment variables are correct
- Ensure Docker image CMD is correct

---

## 🧹 Cleanup

### **Option 1: Scale Down to Zero (Keep Infrastructure)**

```bash
# Stop all tasks
aws ecs update-service \
  --cluster personal-finance-dev-cluster \
  --service personal-finance-dev-service \
  --desired-count 0 \
  --region ap-south-1

# This keeps infrastructure but stops compute costs
```

---

### **Option 2: Destroy Everything**

```bash
cd terraform-ecs/

# Destroy all resources
terraform destroy

# Type 'yes' when prompted
```

**What gets deleted:**
- ✅ ECS Cluster and Service
- ✅ Application Load Balancer
- ✅ Target Groups
- ✅ RDS Database
- ✅ Security Groups
- ✅ IAM Roles
- ✅ CloudWatch Log Groups

**⏱️ Wait Time:** 10-15 minutes

---

### **Verify Cleanup**

```bash
# Check ECS cluster
aws ecs describe-clusters \
  --clusters personal-finance-dev-cluster \
  --region ap-south-1

# Should return cluster with status "INACTIVE"

# Check load balancers
aws elbv2 describe-load-balancers \
  --region ap-south-1 \
  --query 'LoadBalancers[?starts_with(LoadBalancerName, `personal-finance`)].LoadBalancerName'

# Should return empty array
```

---

## 📚 Key Learnings

### **What You Learned:**

1. **ECS Concepts**
   - Task Definitions vs Services vs Clusters
   - Fargate vs EC2 launch types
   - Container orchestration basics

2. **Load Balancing**
   - Application Load Balancer setup
   - Target groups and health checks
   - Traffic routing to containers

3. **Infrastructure as Code**
   - More complex Terraform configuration
   - Multiple resource dependencies
   - IAM roles for services

4. **Auto Scaling**
   - CPU and memory-based scaling
   - Target tracking policies
   - Scaling limits

5. **Monitoring**
   - CloudWatch Logs for containers
   - ECS Container Insights
   - Target health monitoring

---

## 🎯 Next Steps

**✅ Phase 4A Complete!**

Now you can move to:

### **Phase 4B: Local Kubernetes**
Learn Kubernetes fundamentals without AWS costs:
- Deploy to minikube/Docker Desktop
- Master kubectl commands
- Understand Pods, Deployments, Services
- Practice troubleshooting

📖 See: `docs/phase4b-kubernetes-local.md`

---

### **Or: Build Custom Docker Image**

Before moving to Kubernetes, let's build and push our custom Docker image:

1. **Create Amazon ECR Repository**
2. **Build Docker image locally**
3. **Push to ECR**
4. **Update ECS task definition**
5. **Redeploy with custom image**

---

## 📝 Summary

**What We Deployed:**
```
User Request
    ↓
Application Load Balancer (Port 80)
    ↓
ECS Service (Fargate)
    ├── Task 1: Flask Container (Port 5000)
    └── Auto-scales based on CPU/Memory
    ↓
RDS PostgreSQL Database
```

**Key Benefits:**
- ✅ No server management
- ✅ Automatic scaling
- ✅ Load balancing built-in
- ✅ Rolling updates
- ✅ Multi-AZ high availability

**Cost:** ~$47.50/month (vs $26 for EC2)

**When to Use:** Production applications, scalable workloads, team collaboration

---

## 🤔 Questions?

Common questions:

**Q: Why is ECS more expensive than EC2?**  
A: You're paying for the Application Load Balancer (~$18/month) and managed Fargate compute. The trade-off is less management overhead.

**Q: Can I use EC2 launch type to save money?**  
A: Yes! You can switch to EC2 launch type and manage your own instances. This can be cheaper but requires more management.

**Q: How do I deploy code updates?**  
A: Build a new Docker image, push to ECR, update the task definition revision, and ECS will do a rolling update automatically.

**Q: Is this production-ready?**  
A: Almost! For production, you'd want:
- HTTPS with SSL certificate
- Private subnets for containers
- Secrets Manager for credentials
- Multi-AZ RDS deployment
- CloudFront CDN
- WAF for security

---

**🎉 Congratulations on completing Phase 4A!**

You've successfully deployed a containerized application to AWS ECS with auto-scaling and load balancing. This is a significant milestone in your DevOps journey!

**Next:** Phase 4B - Local Kubernetes (No AWS costs while learning!)

---

**Need Help?**
- Check CloudWatch Logs: `/ecs/personal-finance-dev`
- Review troubleshooting section above
- Verify all resources in AWS Console

**Ready for Kubernetes?** 🚀 Proceed to `docs/phase4b-kubernetes-local.md`