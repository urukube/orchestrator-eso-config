output "cluster_secret_store_name" {
  description = "Name of the ClusterSecretStore created"
  value       = "aws-secrets-manager"
}

output "external_secret_names" {
  description = "Map of ExternalSecret name to namespace"
  value       = { for k, v in var.external_secrets : k => v.namespace }
}
