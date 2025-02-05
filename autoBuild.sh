#!/bin/bash

# Configuration variables
GITHUB_REPO_OWNER="darkdevilxy"
GITHUB_REPO_NAME="homeautomation"
GITHUB_BRANCH="main"
APP_NAME="HomeAutomation"
AWS_REGION="ap-southeast-2"
ECR_REPO_NAME="${APP_NAME}-repo"
GITHUB_CONNECTION_NAME="${APP_NAME}-github-connection"

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

echo_step() {
    echo -e "${GREEN}=== $1 ===${NC}"
}

echo_error() {
    echo -e "${RED}ERROR: $1${NC}"
    exit 1
}

# Check AWS CLI is installed
if ! command -v aws &> /dev/null; then
    echo_error "AWS CLI is not installed"
fi

# Get AWS Account ID
AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
if [ $? -ne 0 ]; then
    echo_error "Failed to get AWS Account ID. Check your AWS credentials."
fi

# 1. Create ECR Repository
echo_step "Creating ECR Repository"
aws ecr create-repository \
    --repository-name $ECR_REPO_NAME \
    --image-scanning-configuration scanOnPush=true \
    || echo "ECR repository already exists"

# 2. Create CodeStar Connection for GitHub
echo_step "Creating CodeStar Connection for GitHub"
CONNECTION_ARN=$(aws codestar-connections create-connection \
    --provider-type GitHub \
    --connection-name $GITHUB_CONNECTION_NAME \
    --output text \
    --query 'ConnectionArn')

echo "Please complete the GitHub connection setup in the AWS Console."
echo "Connection ARN: $CONNECTION_ARN"
echo "Press enter after completing the connection setup..."
read

# 3. Create IAM Roles
echo_step "Creating IAM Roles"

# CodeBuild Role
aws iam create-role \
    --role-name "${APP_NAME}-codebuild-role" \
    --assume-role-policy-document '{
        "Version": "2012-10-17",
        "Statement": [
            {
                "Effect": "Allow",
                "Principal": {
                    "Service": "codebuild.amazonaws.com"
                },
                "Action": "sts:AssumeRole"
            }
        ]
    }'

# Attach policies to CodeBuild Role
aws iam put-role-policy \
    --role-name "${APP_NAME}-codebuild-role" \
    --policy-name "${APP_NAME}-codebuild-policy" \
    --policy-document '{
        "Version": "2012-10-17",
        "Statement": [
            {
                "Effect": "Allow",
                "Resource": ["*"],
                "Action": [
                    "ecr:*",
                    "logs:*",
                    "s3:*",
                    "elasticbeanstalk:*",
                    "cloudwatch:*"
                ]
            }
        ]
    }'

# Create Elastic Beanstalk Role
aws iam create-role \
    --role-name "${APP_NAME}-elasticbeanstalk-role" \
    --assume-role-policy-document '{
        "Version": "2012-10-17",
        "Statement": [
            {
                "Effect": "Allow",
                "Principal": {
                    "Service": "elasticbeanstalk.amazonaws.com"
                },
                "Action": "sts:AssumeRole"
            }
        ]
    }'

aws iam attach-role-policy \
    --role-name "${APP_NAME}-elasticbeanstalk-role" \
    --policy-arn arn:aws:iam::aws:policy/service-role/AWSElasticBeanstalkService

# 4. Create S3 Bucket for artifacts
echo_step "Creating S3 Bucket for artifacts"
BUCKET_NAME="${APP_NAME}-artifacts-${AWS_ACCOUNT_ID}"
aws s3 mb "s3://${BUCKET_NAME}" --region $AWS_REGION || true

# 5. Create Elastic Beanstalk Application
echo_step "Creating Elastic Beanstalk Application"
aws elasticbeanstalk create-application \
    --application-name $APP_NAME \
    --description "Docker application with blue-green deployment"

# 6. Create Elastic Beanstalk Environment (Blue)
echo_step "Creating Blue Environment"
aws elasticbeanstalk create-environment \
    --application-name $APP_NAME \
    --environment-name "${APP_NAME}-blue" \
    --solution-stack-name "64bit Amazon Linux 2 v3.6.0 running Docker" \
    --option-settings \
        "Namespace=aws:autoscaling:launchconfiguration,OptionName=IamInstanceProfile,Value=${APP_NAME}-elasticbeanstalk-role" \
        "Namespace=aws:elasticbeanstalk:environment,OptionName=EnvironmentType,Value=LoadBalanced" \
        "Namespace=aws:elasticbeanstalk:environment,OptionName=ServiceRole,Value=${APP_NAME}-elasticbeanstalk-role"

# 7. Create CodeBuild Project
echo_step "Creating CodeBuild Project"
aws codebuild create-project \
    --name "${APP_NAME}-build" \
    --source type=CODEPIPELINE \
    --artifacts type=CODEPIPELINE \
    --environment type=LINUX_CONTAINER,image=aws/codebuild/amazonlinux2-x86_64-standard:4.0,computeType=BUILD_GENERAL1_SMALL,privilegedMode=true \
    --service-role "arn:aws:iam::${AWS_ACCOUNT_ID}:role/${APP_NAME}-codebuild-role"

# 8. Create CodePipeline
echo_step "Creating CodePipeline"
aws codepipeline create-pipeline \
    --pipeline-name "${APP_NAME}-pipeline" \
    --artifact-store location="${BUCKET_NAME}",type=S3 \
    --role-arn "arn:aws:iam::${AWS_ACCOUNT_ID}:role/${APP_NAME}-codebuild-role" \
    --stages '[
        {
            "name": "Source",
            "actions": [
                {
                    "name": "Source",
                    "actionTypeId": {
                        "category": "Source",
                        "owner": "AWS",
                        "provider": "CodeStarSourceConnection",
                        "version": "1"
                    },
                    "configuration": {
                        "ConnectionArn": "'"${CONNECTION_ARN}"'",
                        "FullRepositoryId": "'"${GITHUB_REPO_OWNER}/${GITHUB_REPO_NAME}"'",
                        "BranchName": "'"${GITHUB_BRANCH}"'"
                    },
                    "outputArtifacts": [
                        {
                            "name": "SourceOutput"
                        }
                    ]
                }
            ]
        },
        {
            "name": "Build",
            "actions": [
                {
                    "name": "Build",
                    "actionTypeId": {
                        "category": "Build",
                        "owner": "AWS",
                        "provider": "CodeBuild",
                        "version": "1"
                    },
                    "configuration": {
                        "ProjectName": "'"${APP_NAME}-build"'"
                    },
                    "inputArtifacts": [
                        {
                            "name": "SourceOutput"
                        }
                    ],
                    "outputArtifacts": [
                        {
                            "name": "BuildOutput"
                        }
                    ]
                }
            ]
        },
        {
            "name": "Deploy",
            "actions": [
                {
                    "name": "Deploy",
                    "actionTypeId": {
                        "category": "Deploy",
                        "owner": "AWS",
                        "provider": "ElasticBeanstalk",
                        "version": "1"
                    },
                    "configuration": {
                        "ApplicationName": "'"${APP_NAME}"'",
                        "EnvironmentName": "'"${APP_NAME}-blue"'"
                    },
                    "inputArtifacts": [
                        {
                            "name": "BuildOutput"
                        }
                    ]
                }
            ]
        }
    ]'

echo_step "Setup Complete!"
echo "Next steps:"
echo "1. Update the following variables in the GitHub repository:"
echo "   - GITHUB_REPO_OWNER"
echo "   - GITHUB_REPO_NAME"
echo "   - GITHUB_BRANCH"
echo "2. Complete the GitHub connection setup in AWS Console"
echo "3. Push your code to trigger the pipeline"