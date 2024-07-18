
terraform {
  source = "github.com/liatrio/dora-lambda-tf-module-demo-elite?ref=v0.2.0"
}

include "root" {
  path   = find_in_parent_folders()
}

locals {
  common_vars = yamldecode(file(find_in_parent_folders("common_vars.yaml")))
}

inputs = {
  region = "${local.common_vars.aws_region}"
}
