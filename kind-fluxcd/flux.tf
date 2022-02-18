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
}

resource "kustomization_resource" "flux" {
  for_each = data.kustomization_overlay.flux.ids
  manifest = data.kustomization_overlay.flux.manifests[each.value]

  depends_on = [kubernetes_namespace.flux]
}
