#!/bin/bash

# Run tofu apply
terragrunt apply

terraform_output=$(terragrunt output -json)

# Save terraform output as a repository secret
echo "$terraform_output" | jq ".role_arn.value" | xargs -I {} gh variable set AWS_IAM_ROLE --body {}
echo "$terraform_output" | jq ".aws_region.value" | xargs -I {} gh variable set AWS_REGION --body {}
