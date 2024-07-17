output "aws_region" {
  value = var.aws_region
}

output "role_arn" {
  value = aws_iam_role.gha_oidc_role.arn
}
