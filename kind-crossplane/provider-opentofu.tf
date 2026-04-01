locals {
  namespaces = ["vms", "vpc"]
}

resource "kubernetes_namespace_v1" "namespaces" {
  for_each = toset(local.namespaces)

  metadata { name = each.value }
}

data "kustomization_overlay" "provider_opentofu" {
  for_each = toset(local.namespaces)

  resources = ["kustomize/crossplane-provider-opentofu/"]

  patches {
    patch = jsonencode([
      {
        op    = "replace"
        path  = "/metadata/name"
        value = "crossplane-provider-opentofu-${each.value}"
      },
      {
        op    = "replace"
        path  = "/spec/package"
        value = "docker.io/kurtis/crossplane-opentofu-provider:060c989"
      },
      {
        op    = "replace"
        path  = "/spec/runtimeConfigRef/name"
        value = "opentofu-config-${each.value}"
      }
    ])
    target {
      group = "pkg.crossplane.io"
      kind  = "Provider"
      name  = "crossplane-provider-opentofu"
    }
  }

  patches {
    patch = jsonencode([
      {
        op    = "replace"
        path  = "/metadata/name"
        value = "opentofu-config-${each.value}"
      },
      {
        op   = "add"
        path = "/spec/deploymentTemplate/spec/template/spec/containers"
        value = [
          {
            name = "package-runtime",
            env = [
              { name = "WATCH_NAMESPACE", value = each.value },
              { name = "USER", value = "crossplane" }
            ]
          }
        ]
      }
    ])
    target {
      group = "pkg.crossplane.io"
      kind  = "DeploymentRuntimeConfig"
      name  = "opentofu-config"
    }
  }
}

resource "kustomization_resource" "provider_opentofu" {
  for_each = merge([
    for ns, overlay in data.kustomization_overlay.provider_opentofu :
    {
      for id in overlay.ids :
      "${ns}-${id}" => {
        manifest = overlay.manifests[id]
      }
    }
  ]...)

  manifest = each.value.manifest
}

data "external" "provider_opentofu_latest_release" {
  program = ["python3", "${path.module}/get_latest_release.py"]

  query = {
    repo = "upbound/provider-opentofu"
  }
}

locals {
  provider_opentofu_latest_release = data.external.provider_opentofu_latest_release.result["tag_name"]
}
