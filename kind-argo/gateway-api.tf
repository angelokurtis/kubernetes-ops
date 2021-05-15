data "kustomization_build" "gateway_api" {
  path = "https://github.com/kubernetes-sigs/gateway-api/config/crd?ref=v0.3.0"
}

resource "kustomization_resource" "gateway_api" {
  for_each = data.kustomization_build.gateway_api.ids
  manifest = data.kustomization_build.gateway_api.manifests[each.value]
}
