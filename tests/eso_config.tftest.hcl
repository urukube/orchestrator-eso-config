mock_provider "kubectl" {}

run "creates_cluster_secret_store" {
  variables {
    aws_region = "us-east-1"
  }

  assert {
    condition     = kubectl_manifest.cluster_secret_store.kind == "ClusterSecretStore"
    error_message = "Expected a ClusterSecretStore resource"
  }
}

run "creates_external_secrets" {
  variables {
    aws_region = "us-east-1"
    external_secrets = {
      argocd-github-token = {
        namespace          = "argocd"
        target_secret_name = "argocd-github-token"
        creation_policy    = "Owner"
        mappings = [
          { secret_key = "token", remote_key = "platform/github/github-token" } # checkov:skip=CKV_SECRET_6: SM path, not a secret value
        ]
      }
    }
  }

  assert {
    condition     = length(kubectl_manifest.external_secret) == 1
    error_message = "Expected one ExternalSecret"
  }
}

run "empty_external_secrets_creates_none" {
  variables {
    aws_region       = "us-east-1"
    external_secrets = {}
  }

  assert {
    condition     = length(kubectl_manifest.external_secret) == 0
    error_message = "Expected no ExternalSecrets when map is empty"
  }
}
