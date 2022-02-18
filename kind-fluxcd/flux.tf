locals {
  flux = { version = "v0.27.0" }
}

data "kustomization_overlay" "flux" {
  resources = [
    "https://github.com/fluxcd/flux2/manifests/bases/source-controller?ref=${local.flux.version}",
    "https://github.com/fluxcd/flux2/manifests/bases/kustomize-controller?ref=${local.flux.version}",
    "https://github.com/fluxcd/flux2/manifests/bases/helm-controller?ref=${local.flux.version}",
    "https://github.com/fluxcd/flux2/manifests/rbac?ref=${local.flux.version}",
    "https://github.com/fluxcd/flux2/manifests/policies?ref=${local.flux.version}",
  ]
  namespace = var.flux_namespace
  patches {
    target = { apiVersion = "rbac.authorization.k8s.io/v1", kind = "ClusterRoleBinding", name = "cluster-reconciler" }
    patch  = yamlencode([
    for i in range(2) : { op = "replace", path = "/subjects/${i}/namespace", value = var.flux_namespace }
    ])
  }
  patches {
    target = { apiVersion = "rbac.authorization.k8s.io/v1", kind = "ClusterRoleBinding", name = "crd-controller" }
    patch  = yamlencode([
    for i in range(6) : { op = "replace", path = "/subjects/${i}/namespace", value = var.flux_namespace }
    ])
  }
}

resource "kustomization_resource" "flux" {
  for_each = data.kustomization_overlay.flux.ids
  manifest = data.kustomization_overlay.flux.manifests[each.value]

  depends_on = [kubernetes_namespace.flux]
}

# used for troubleshooting
# resource "local_file" "flux" {
#   for_each = data.kustomization_overlay.flux.ids
#   content  = yamlencode(jsondecode(data.kustomization_overlay.flux.manifests[each.value]))
#   filename = "${path.module}/flux/${each.value}.yaml"
# }
