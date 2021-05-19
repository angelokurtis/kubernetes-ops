data "kustomization_overlay" "contour_operator" {
  resources = [
    "https://github.com/projectcontour/contour-operator/config/default?ref=v1.15.1"
  ]

  namespace = var.contour_namespace
}

resource "kustomization_resource" "contour" {
  for_each = data.kustomization_overlay.contour_operator.ids
  manifest = data.kustomization_overlay.contour_operator.manifests[each.value]
}