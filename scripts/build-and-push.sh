#!/bin/bash
set -e

# Configuration
AWS_REGION="ap-south-1"
AWS_ACCOUNT_ID="878740762729"  # Your account ID from outputs
ECR_REPOSITORY="personal-finance-dev"
IMAGE_TAG="latest"

# Full ECR URL
ECR_URL="${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${ECR_REPOSITORY}"

echo "================================="
echo "Building and Pushing Docker Image"
echo "================================="
echo "ECR Repository: ${ECR_URL}"
echo "Image Tag: ${IMAGE_TAG}"
echo ""

# Step 1: Authenticate Docker with ECR
echo "Step 1: Authenticating with ECR..."
aws ecr get-login-password --region ${AWS_REGION} | \
    docker login --username AWS --password-stdin ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com

echo "✓ Authentication successful"
echo ""

# Step 2: Build Docker image
echo "Step 2: Building Docker image..."
docker build -t ${ECR_REPOSITORY}:${IMAGE_TAG} .

echo "✓ Image built successfully"
echo ""

# Step 3: Tag image for ECR
echo "Step 3: Tagging image for ECR..."
docker tag ${ECR_REPOSITORY}:${IMAGE_TAG} ${ECR_URL}:${IMAGE_TAG}

echo "✓ Image tagged successfully"
echo ""

# Step 4: Push image to ECR
echo "Step 4: Pushing image to ECR..."
docker push ${ECR_URL}:${IMAGE_TAG}

echo "✓ Image pushed successfully"
echo ""

# Step 5: Get image digest
IMAGE_DIGEST=$(aws ecr describe-images \
    --repository-name ${ECR_REPOSITORY} \
    --image-ids imageTag=${IMAGE_TAG} \
    --region ${AWS_REGION} \
    --query 'imageDetails[0].imageDigest' \
    --output text)

echo "================================="
echo "Build Complete!"
echo "================================="
echo "Image URL: ${ECR_URL}:${IMAGE_TAG}"
echo "Image Digest: ${IMAGE_DIGEST}"
echo ""
echo "Next steps:"
echo "1. Update terraform-ecs/variables.tf with:"
echo "   docker_image = \"${ECR_URL}:${IMAGE_TAG}\""
echo "2. Run: terraform apply"
echo "================================="