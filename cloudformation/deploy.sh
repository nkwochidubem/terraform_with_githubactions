#!/bin/bash

# Configuration
STACK_NAME="oidc-Stack"
TEMPLATE_FILE="template.yaml"
REPO_PATH="nkwochidubem/terraform_with_githubactions"
REGION="us-east-1"

echo "Step 0: Checking for existing failed stacks..."
STACK_STATUS=$(aws cloudformation describe-stacks --stack-name $STACK_NAME --region $REGION --query "Stacks[0].StackStatus" --output text 2>/dev/null)

if [[ "$STACK_STATUS" == "ROLLBACK_COMPLETE" || "$STACK_STATUS" == "CREATE_FAILED" ]]; then
    echo "⚠️  Stack $STACK_NAME is in a failed state ($STACK_STATUS). Deleting it first..."
    aws cloudformation delete-stack --stack-name $STACK_NAME --region $REGION
    aws cloudformation wait stack-delete-complete --stack-name $STACK_NAME --region $REGION
    echo "✅ Old stack cleared."
fi

echo "Step 1: Validating template..."
aws cloudformation validate-template --template-body file://$TEMPLATE_FILE > /dev/null
if [ $? -eq 0 ]; then
    echo "✅ Template syntax is valid."
else
    echo "❌ Template validation failed."
    exit 1
fi

echo "Step 2: Creating stack '$STACK_NAME'..."
# Added CAPABILITY_NAMED_IAM to handle custom role names
aws cloudformation create-stack \
    --stack-name $STACK_NAME \
    --template-body file://$TEMPLATE_FILE \
    --parameters ParameterKey=Repo,ParameterValue=$REPO_PATH \
    --capabilities CAPABILITY_IAM CAPABILITY_NAMED_IAM \
    --region $REGION

echo "Step 3: Waiting for stack creation to complete..."
aws cloudformation wait stack-create-complete --stack-name $STACK_NAME --region $REGION

if [ $? -eq 0 ]; then
    echo "🚀 Stack '$STACK_NAME' created successfully!"
    echo "--- Stack Outputs ---"
    aws cloudformation describe-stacks --stack-name $STACK_NAME --query 'Stacks[0].Outputs' --output table
else
    echo "❌ Stack creation failed. Check AWS Console Events for details."
    exit 1
fi