# Bootstrap

This module is never intended to be ran in CI. This is for creating the necessary roles that can deploy the underlying app. It comes with a bootstrap.sh script that simply
runs OpenTofu to create the role and then set the role as a secret in the repo.

## Getting started
`brew bundle`

`./bootstrap.sh`
