# You can only have a single Federated IdP per AWS account for each unique URL.
# So use the data source to check if the provider already exists before creating it.
data "aws_iam_openid_connect_provider" "github" {
  url = "https://token.actions.githubusercontent.com"
}

data "tls_certificate" "github_thumbprint" {
  url = "https://token.actions.githubusercontent.com/.well-known/openid-configuration"
}

resource "aws_iam_openid_connect_provider" "github" {
  count = data.aws_iam_openid_connect_provider.github.arn != "" ? 0 : 1
  url   = "https://token.actions.githubusercontent.com"

  # All roles go here.
  # You can find these in the audience of the Github OIDC tokens
  client_id_list = ["sts.amazonaws.com"]

  thumbprint_list = [
    data.tls_certificate.github_thumbprint.certificates[0].sha1_fingerprint
  ]
}
