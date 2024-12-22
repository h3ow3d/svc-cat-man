#!/bin/bash

# Setup phase: Assign Account ID and AWS_REGION to variables
echo "+++ Assigning AWS_ACCOUNT_ID and AWS_REGION to variables..."
AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query "Account" --output text)
AWS_REGION="eu-west-2"
STACK_NAME="SvcCatMan"

# Deploy the CloudFormation stack
echo "+++ Deploying the CloudFormation stack for pre-requisites..."
aws cloudformation deploy \
  --template-file bootstrap/001-pre-requisites.yaml \
  --stack-name "${STACK_NAME}-pre-requisites" \
  --capabilities CAPABILITY_NAMED_IAM \
  --region "$AWS_REGION"

# Get the output value of GitHubCodeConnection from the deployed stack
echo "+++ Retrieving the GitHubCodeConnection from the deployed stack..."
GITHUB_CODE_CONNECTION=$(aws cloudformation describe-stacks \
  --stack-name "${STACK_NAME}-pre-requisites" \
  --query "Stacks[0].Outputs[?OutputKey=='GitHubCodeConnection'].OutputValue" \
  --output text)

# Extract the connection ID from the ARN
echo "+++ Extracting the connection ID from the GitHubCodeConnection ARN..."
CODE_CONNECTION_ID=$(echo "$GITHUB_CODE_CONNECTION" | awk -F "/" '{print $NF}')

# Open the Code Connection URL in the default browser
echo "+++ Opening the Code Connection URL in the default browser..."
CODE_CONNECTION_URL="https://$AWS_REGION.console.aws.amazon.com/codesuite/settings/$AWS_ACCOUNT_ID/$AWS_REGION/codeconnections/connections/$CODE_CONNECTION_ID"

if command -v xdg-open &> /dev/null; then
  xdg-open "$ConnectionURL"
elif command -v open &> /dev/null; then
  open "$ConnectionURL"
else
  echo "Please manually open the following URL to approve the connection:"
  echo "$ConnectionURL"
fi

# Poll the connection status until it becomes AVAILABLE
echo "Polling the connection status until it becomes AVAILABLE..."
while true; do
  ConnectionStatus=$(aws codestar-connections get-connection \
    --connection-arn "$GITHUB_CODE_CONNECTION" \
    --region "$AWS_REGION" \
    --query "Connection.ConnectionStatus" \
    --output text)

  echo "Current status: $ConnectionStatus"

  if [ "$ConnectionStatus" == "AVAILABLE" ]; then
    echo "Connection is now AVAILABLE."
    break
  fi

  sleep 10

done

# Deploy the management pipeline stack
echo "Deploying the CloudFormation stack for the management pipeline..."
aws cloudformation deploy \
  --template-file bootstrap/002-management-pipeline.yaml \
  --stack-name "${STACK_NAME}-management-pipeline" \
  --capabilities CAPABILITY_NAMED_IAM \
  --region "$AWS_REGION"

# Deploy the repository link stack
echo "Deploying the CloudFormation stack for the repository link..."
aws cloudformation deploy \
  --template-file bootstrap/003-repository-link.yaml \
  --stack-name "${STACK_NAME}-repository-link" \
  --region "$AWS_REGION"

# Get the output value of RepositoryLinkId from the deployed stack
echo "Retrieving the RepositoryLinkId from the deployed stack..."
REPOSITORY_LINK_ID=$(aws cloudformation describe-stacks \
  --stack-name "${STACK_NAME}-repository-link" \
  --query "Stacks[0].Outputs[?OutputKey=='RepositoryLinkId'].OutputValue" \
  --output text)

# Configure GitSync for the management pipeline
echo "Configuring GitSync for the management pipeline..."
aws codeconnections create-sync-configuration \
  --connection-arn "$GITHUB_CODE_CONNECTION" \
  --repository-link-id "$REPOSITORY_LINK_ID" \
  --branch "main" \
  --config-file "gitsync-deployment-file.yaml" \
  --resource-name "${STACK_NAME}-management-pipeline" \
  --role-arn "arn:aws:iam::${AWS_ACCOUNT_ID}:role/SvcCatManSyncRole" \
  --sync-type "CFN_STACK_SYNC" \
  --region "$AWS_REGION"
