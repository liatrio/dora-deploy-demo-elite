include {
  path = find_in_parent_folders()
}

inputs = {
    aws_region = "include.root.locals.root_envs.region"
}
