# Terraform ECS Deployment

Infrastructure as Code for deploying Personal Finance Tracker to AWS ECS (Elastic Container Service) with Fargate.

---

## 📁 Files

| File | Purpose |
|------|---------|
| `main.tf` | Provider configuration, VPC data sources, RDS, CloudWatch |
| `ecs.tf` | ECS cluster, task definition, service, IAM roles, auto-scaling |
| `alb.tf` | Application Load Balancer, target group, listener, security groups |
| `variables.tf` | Input variables for customization |
| `outputs.tf` | Output values after deployment |

---

## 🚀 Quick Start

```bash
# 1. Navigate to directory
cd terraform-ecs/

# 2. Initialize Terraform
terraform init

# 3. Review plan
terraform plan

# 4. Deploy
terraform apply

# 5. Get ALB URL
terraform output alb_url

# 6. Test
curl $(terraform output -raw alb_url)/
```

---

## ⚙️ Configuration

### **Default Values**

- **Region:** ap-south-1 (Mumbai)
- **CPU:** 256 (0.25 vCPU)
- **Memory:** 512 MB
- **Desired Count:** 1 task
- **Auto-scaling:** 1-4 tasks based on CPU/Memory

### **Customize**

Edit `variables.tf` or create `terraform.tfvars`:

```hcl
project_name = "my-app"
environment = "prod"
ecs_task_cpu = "512"
ecs_task_memory = "1024"
ecs_desired_count = 2
ecs_autoscale_max_capacity = 10
```

---

## 📊 Resources Created

- **1x** ECS Cluster
- **1x** ECS Service
- **1x** ECS Task Definition
- **1x** Application Load Balancer
- **1x** Target Group
- **1x** RDS PostgreSQL (db.t3.micro)
- **3x** Security Groups (ALB, ECS Tasks, RDS)
- **2x** IAM Roles (Task Execution, Task Role)
- **1x** CloudWatch Log Group
- **2x** Auto Scaling Policies (CPU, Memory)

---

## 💰 Estimated Cost

**Monthly:** ~$47.50 USD (ap-south-1)

- ECS Fargate: ~$13
- RDS db.t3.micro: ~$15
- Application Load Balancer: ~$18
- Data Transfer: ~$1
- CloudWatch Logs: ~$0.50

**Free Tier:** First year eligible for RDS free hours

---

## 📖 Documentation

Full deployment guide: `../docs/phase4a-ecs-deployment.md`

---

## 🔧 Troubleshooting

### Tasks Not Starting

```bash
# Check service events
aws ecs describe-services \
  --cluster personal-finance-dev-cluster \
  --services personal-finance-dev-service \
  --region ap-south-1
```

### View Logs

```bash
aws logs tail /ecs/personal-finance-dev --follow
```

### Check Target Health

```bash
aws elbv2 describe-target-health \
  --target-group-arn $(terraform output -raw target_group_arn)
```

---

## 🧹 Cleanup

```bash
# Destroy all resources
terraform destroy

# Type 'yes' when prompted
```

---

## 📝 Notes

- **Docker Image:** Currently uses placeholder. Update `docker_image` variable with your ECR image URI.
- **Database:** RDS is private (not publicly accessible).
- **Security Groups:** Configured for development. Restrict for production.
- **HTTPS:** Not configured. Add ACM certificate and update ALB listener for production.

---

## 🔗 Related

- **Phase 3 (EC2):** `../terraform/`
- **Phase 4B (Local K8s):** `../kubernetes/local/`
- **Phase 4C (EKS):** `../terraform-eks/`

---

**Need help?** See full documentation in `../docs/phase4a-ecs-deployment.md`