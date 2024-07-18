remote_state {
  backend = "s3"
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite"
  }
  config = {
    bucket         = "${local.common_vars.repo_name}-state-bucket"
    key            = "${path_relative_to_include()}/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "${local.common_vars.repo_name}-lock"
  }
}


locals {
  common_vars = yamldecode(file("common_vars.yaml"))
}
