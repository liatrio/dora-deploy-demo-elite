
terraform {
  source = "github.com/liatrio/dora-lambda-tf-module-demo-elite?ref=main"
}

include "root" {
  path   = find_in_parent_folders()
}

locals {
  common_vars = yamldecode(file(find_in_parent_folders("common_vars.yaml")))
  env_vars = yamldecode(file("vars.yaml"))
}

inputs = {
  aws_region = "${local.common_vars.aws_region}"
  app_name = "${local.env_vars.env}-${local.common_vars.app_name}"
}
