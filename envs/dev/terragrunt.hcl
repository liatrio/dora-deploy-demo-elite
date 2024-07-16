
terraform {
  source = "github.com/liatrio/dora-lambda-tf-module-demo-elite?ref=v0.2.0"
}

include "root" {
  path   = find_in_parent_folders()
  expose = true
}

inputs = {
  region = "${include.root.locals.common.aws_region}"
}
