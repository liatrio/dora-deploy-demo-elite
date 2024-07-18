#!/bin/bash

set -e

# Run tofu apply
terragrunt apply

terraform_output=$(terragrunt output -json)

# Save terraform output as a repository secret
echo "$terraform_output" | jq ".plan_role_arn.value" | xargs -I {} gh variable set AWS_PLAN_IAM_ROLE --body {}
echo "$terraform_output" | jq ".deploy_role_arn.value" | xargs -I {} gh variable set AWS_DEPLOY_IAM_ROLE --body {}
echo "$terraform_output" | jq ".aws_region.value" | xargs -I {} gh variable set AWS_REGION --body {}
