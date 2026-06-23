resource "kubectl_manifest" "cluster_secret_store" {
  server_side_apply = true
  wait              = true

  yaml_body = yamlencode({
    apiVersion = "external-secrets.io/v1beta1"
    kind       = "ClusterSecretStore"
    metadata = {
      name = "aws-secrets-manager"
    }
    spec = {
      provider = {
        aws = {
          service = "SecretsManager"
          region  = var.aws_region
          auth = {
            jwt = {
              serviceAccountRef = {
                name      = var.eso_service_account_name
                namespace = var.eso_namespace
              }
            }
          }
        }
      }
    }
  })
}

resource "kubectl_manifest" "external_secret" {
  for_each          = var.external_secrets
  server_side_apply = true
  wait              = true

  yaml_body = yamlencode({
    apiVersion = "external-secrets.io/v1beta1"
    kind       = "ExternalSecret"
    metadata = {
      name      = each.key
      namespace = each.value.namespace
    }
    spec = {
      refreshInterval = var.refresh_interval
      secretStoreRef = {
        kind = "ClusterSecretStore"
        name = "aws-secrets-manager"
      }
      target = {
        name           = each.value.target_secret_name
        creationPolicy = each.value.creation_policy
      }
      data = [for mapping in each.value.mappings : {
        secretKey = mapping.secret_key
        remoteRef = {
          key = mapping.remote_key
        }
      }]
    }
  })

  depends_on = [kubectl_manifest.cluster_secret_store]
}
