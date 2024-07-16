data "aws_iam_policy_document" "trust_policy" {
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
      values   = ["repo:${var.deploy_repo}:ref:refs/heads/main",
                  "repo:${var.deploy_repo}:environment:dev"]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]

    }
  }
}

resource "aws_iam_role" "external_dns_gha_role" {
  name                = "${var.app_name}-oidc-role"
  assume_role_policy  = data.aws_iam_policy_document.trust_policy.json
  managed_policy_arns = [
    "arn:aws:iam::aws:policy/AdministratorAccess"
  ]
}
