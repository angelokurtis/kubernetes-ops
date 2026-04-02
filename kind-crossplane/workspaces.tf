locals {
  workspaces = [
    "dev",
    "prod",
    "test",
  ]
}

resource "kubernetes_namespace_v1" "namespaces" {
  for_each = toset(local.workspaces)

  metadata {
    name = each.key
  }
}

resource "kubectl_manifest" "workspaces" {
  for_each = toset(local.workspaces)

  yaml_body = <<-YAML
    apiVersion: opentofu.m.upbound.io/v1beta1
    kind: Workspace
    metadata:
      name: ${each.key}-workspace
      namespace: ${kubernetes_namespace_v1.namespaces[each.key].metadata[0].name}
    spec:
      providerConfigRef:
        kind: ClusterProviderConfig
        name: random
      forProvider:
        initArgs:
          - "-upgrade"
        module: |
          resource "random_pet" "name" {
            length = 2
          }
          output "generated_name" {
            value = random_pet.name.id
          }
        source: Inline
  YAML

  depends_on = [kubernetes_job_v1.wait_flux_crd]
}

resource "kubectl_manifest" "random_clusterproviderconfig" {
  yaml_body = <<-YAML
    apiVersion: opentofu.m.upbound.io/v1beta1
    kind: ClusterProviderConfig
    metadata:
      name: random
    spec:
      pluginCache: true
      configuration: |
        terraform {
          required_providers {
            random = {
              source = "hashicorp/random"
              version = "3.8.1"
            }
          }
        }
        provider "random" {
        }
  YAML

  depends_on = [kubernetes_job_v1.wait_flux_crd]
}
