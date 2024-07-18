#!/bin/bash

set -e

# Run tofu apply
terragrunt apply

terraform_output=$(terragrunt output -json)

# Save terraform output as a repository secret
echo "$terraform_output" | jq ".plan_role_arn.value" | xargs -I {} gh variable set AWS_PLAN_IAM_ROLE --body {}
echo "$terraform_output" | jq ".deploy_role_arn.value" | xargs -I {} gh variable set AWS_DEPLOY_IAM_ROLE --body {}
echo "$terraform_output" | jq ".aws_region.value" | xargs -I {} gh variable set AWS_REGION --body {}

# Create a dev environment if one does not exist
org_name_response=$(gh repo view --json owner,name)
org=$(echo "$org_name_response" | jq -r ".owner.login")
repo=$(echo "$org_name_response" | jq -r ".name")

envs=$(gh api \
  -X GET \
  -H "Accept: application/vnd.github.v3+json" \
  /repos/$org/$repo/environments \
  -q '.environments.[].name')



# Create a dev environment if one does not exist
if ! echo "$envs" | grep -q "^dev$"; then
    echo
    echo "Creating dev environment"
    PAGER=cat gh api \
    -X PUT \
    -H "Accept: application/vnd.github.v3+json" \
    /repos/$org/$repo/environments/dev
fi
