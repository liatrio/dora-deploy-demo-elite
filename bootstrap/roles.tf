locals {
  alpha_numeric_repo_name = replace(var.repo_name, "/[^a-zA-Z0-9]/", "")
  bucket_name             = "${var.repo_name}-state-bucket"
  dynamo_db_name          = "${var.repo_name}-lock"
}

data "aws_iam_policy_document" "terragrunt_admin" {
  statement {
    sid = "AllowS3ActionsFor${local.alpha_numeric_repo_name}"
    actions = [ "s3:*" ]
    resources = [
      "arn:aws:s3:::${local.bucket_name}",
    ]
  }

  statement {
    sid = "AllowCreateAndUpdateDynamoDBActionsFor${local.alpha_numeric_repo_name}"

    actions = [
      "dynamodb:PutItem",
      "dynamodb:GetItem",
      "dynamodb:DeleteItem",
      "dynamodb:DescribeTable",
      "dynamodb:CreateTable",
    ]

    resources = [
      "arn:aws:dynamodb:*:*:table/${local.dynamo_db_name}",
    ]
  }

  statement {
    sid = "AllowTagAndUntagDynamoDBActions"

    actions = [
      "dynamodb:TagResource",
      "dynamodb:UntagResource",
    ]

    resources = [
      "*",
    ]
  }
}

resource "aws_iam_policy" "terragrunt_admin" {
  name        = "TerragruntAdminAccess${local.alpha_numeric_repo_name}"
  policy      = data.aws_iam_policy_document.terragrunt_admin.json
  description = "Grants permissions needed by terragrunt to manage Terraform remote state"
}

data "aws_iam_policy_document" "deploy_trust_policy" {
  statement {
    actions = [
      "sts:TagSession",
      "sts:AssumeRoleWithWebIdentity"
    ]

    # We use StringLike on the Arn to control this
    principals {
      type        = "Federated"
      identifiers = [data.aws_iam_openid_connect_provider.github.arn]
    }

    condition {
      test     = "StringLike"
      variable = "token.actions.githubusercontent.com:sub"
      values   = ["repo:liatrio/${var.repo_name}:ref:refs/heads/main",
                  "repo:liatrio/${var.repo_name}:environment:dev"]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]

    }
  }
}

data "aws_iam_policy_document" "plan_trust_policy" {
  statement {
    actions = [
      "sts:TagSession",
      "sts:AssumeRoleWithWebIdentity"
    ]

    # We use StringLike on the Arn to control this
    principals {
      type        = "Federated"
      identifiers = [data.aws_iam_openid_connect_provider.github.arn]
    }

    condition {
      test     = "StringLike"
      variable = "token.actions.githubusercontent.com:sub"
      values   = ["repo:liatrio/${var.repo_name}:*"]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]

    }
  }
}

resource "aws_iam_role" "gha_oidc_deploy_role" {
  name                = "${var.repo_name}-oidc-deploy-role"
  assume_role_policy  = data.aws_iam_policy_document.deploy_trust_policy.json
  managed_policy_arns = [
    "arn:aws:iam::aws:policy/AdministratorAccess",
    aws_iam_policy.terragrunt_admin.arn
  ]
}

resource "aws_iam_role" "gha_oidc_plan_role" {
  name                = "${var.repo_name}-oidc-plan-role"
  assume_role_policy  = data.aws_iam_policy_document.plan_trust_policy.json
  managed_policy_arns = [
    "arn:aws:iam::aws:policy/ReadOnlyAccess",
    aws_iam_policy.terragrunt_admin.arn
  ]
}
