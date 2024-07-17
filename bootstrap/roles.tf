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

resource "aws_iam_role" "gha_oidc_role" {
  name                = "${var.repo_name}-oidc-role"
  assume_role_policy  = data.aws_iam_policy_document.trust_policy.json
  managed_policy_arns = [
    "arn:aws:iam::aws:policy/AdministratorAccess"
  ]
}
