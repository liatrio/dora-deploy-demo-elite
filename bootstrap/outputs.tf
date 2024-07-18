output "aws_region" {
  value = var.aws_region
}

output "deploy_role_arn" {
  value = aws_iam_role.gha_oidc_deploy_role.arn
}

output "plan_role_arn" {
  value = aws_iam_role.gha_oidc_plan_role.arn
}
