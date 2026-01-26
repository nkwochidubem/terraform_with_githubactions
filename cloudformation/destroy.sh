#!/bin/bash

# Configuration
STACK_NAME="Terraform-Backend-Stack"
REGION="us-east-1"

echo "Step 1: Identifying resources to clean up..."

# Get all S3 buckets created by the stack
BUCKETS=$(aws cloudformation describe-stack-resources \
    --stack-name $STACK_NAME \
    --query "StackResources[?ResourceType=='AWS::S3::Bucket'].PhysicalResourceId" \
    --output text)

# Step 2: Empty buckets before deletion
for BUCKET in $BUCKETS; do
    echo "⚠️  Emptying bucket: $BUCKET"
    aws s3 rm s3://$BUCKET --recursive
    
    # If you have versioning enabled, you must also remove all versions
    # aws s3api delete-objects --bucket $BUCKET --delete "$(aws s3api list-object-versions --bucket $BUCKET --query='{Objects: Versions[].{Key:Key,VersionId:VersionId}}' --output json)"
done

echo "Step 3: Initiating stack deletion..."
aws cloudformation delete-stack --stack-name $STACK_NAME --region $REGION

echo "Step 4: Waiting for stack to be fully destroyed..."
aws cloudformation wait stack-delete-complete --stack-name $STACK_NAME --region $REGION

if [ $? -eq 0 ]; then
    echo "✅ CloudFormation stack and resources deleted."
else
    echo "❌ Stack deletion failed. It might be due to a non-empty bucket or IAM issues."
    exit 1
fi

echo "🚀 Teardown complete."