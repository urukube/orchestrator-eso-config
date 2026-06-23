# orchestrator-eso-config

Terraform module that configures ESO (External Secrets Operator) on the orchestrator cluster.
Creates a `ClusterSecretStore` pointing to AWS Secrets Manager and one `ExternalSecret` per entry
in `var.external_secrets`.

This module must run in a **separate pipeline step after** the step that installs ESO via Helm.
The `kubectl` provider caches API discovery at plan time — if ESO CRDs are not yet registered
when this module initialises, it will fail.

## Usage

```hcl
module "eso_config" {
  source = "git::https://github.com/urukube/orchestrator-eso-config.git?ref=v1.0.0"

  aws_region = "us-east-1"

  external_secrets = {
    argocd-github-token = {
      namespace          = "argocd"
      target_secret_name = "argocd-github-token"
      creation_policy    = "Owner"
      mappings = [
        { secret_key = "token", remote_key = "platform/github/github-token" }
      ]
    }
    argocd-admin-password = {
      namespace          = "argocd"
      target_secret_name = "argocd-secret"
      creation_policy    = "Merge"
      mappings = [
        { secret_key = "admin.password", remote_key = "platform/argocd/admin-password" }
      ]
    }
  }
}
```

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.5.0 |
| <a name="requirement_kubectl"></a> [kubectl](#requirement\_kubectl) | >= 1.14.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_kubectl"></a> [kubectl](#provider\_kubectl) | >= 1.14.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [kubectl_manifest.cluster_secret_store](https://registry.terraform.io/providers/gavinbunney/kubectl/latest/docs/resources/manifest) | resource |
| [kubectl_manifest.external_secret](https://registry.terraform.io/providers/gavinbunney/kubectl/latest/docs/resources/manifest) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | AWS region where Secrets Manager secrets are stored | `string` | n/a | yes |
| <a name="input_eso_namespace"></a> [eso\_namespace](#input\_eso\_namespace) | Kubernetes namespace where ESO is installed | `string` | `"external-secrets"` | no |
| <a name="input_eso_service_account_name"></a> [eso\_service\_account\_name](#input\_eso\_service\_account\_name) | Name of the ESO Kubernetes service account with IRSA annotation for Secrets Manager | `string` | `"eso-service-account"` | no |
| <a name="input_external_secrets"></a> [external\_secrets](#input\_external\_secrets) | Map of ExternalSecret resources to create. Key is the ExternalSecret name.<br/>Each entry defines the namespace, target K8s secret, creation policy, and<br/>the list of SM path → K8s key mappings.<br/><br/>Example:<br/>  external\_secrets = {<br/>    argocd-github-token = {<br/>      namespace          = "argocd"<br/>      target\_secret\_name = "argocd-github-token"<br/>      creation\_policy    = "Owner"<br/>      mappings = [<br/>        { secret\_key = "token", remote\_key = "platform/github/github-token" }<br/>      ]<br/>    }<br/>  } | <pre>map(object({<br/>    namespace          = string<br/>    target_secret_name = string<br/>    creation_policy    = optional(string, "Owner")<br/>    mappings = list(object({<br/>      secret_key = string<br/>      remote_key = string<br/>    }))<br/>  }))</pre> | `{}` | no |
| <a name="input_refresh_interval"></a> [refresh\_interval](#input\_refresh\_interval) | How often ESO polls Secrets Manager for changes | `string` | `"1h"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_cluster_secret_store_name"></a> [cluster\_secret\_store\_name](#output\_cluster\_secret\_store\_name) | Name of the ClusterSecretStore created |
| <a name="output_external_secret_names"></a> [external\_secret\_names](#output\_external\_secret\_names) | Map of ExternalSecret name to namespace |
<!-- END_TF_DOCS -->
