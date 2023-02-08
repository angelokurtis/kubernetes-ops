locals {
  helm_repositories = {
    haproxy-ingress      = { repository = "https://haproxy-ingress.github.io/charts" }
    prometheus-community = { repository = "https://prometheus-community.github.io/helm-charts" }
    strimzi              = { repository = "https://strimzi.io/charts/" }
  }
}

resource "kubectl_manifest" "helm_repository" {
  for_each = local.helm_repositories

  server_side_apply = true
  yaml_body         = yamlencode({
    apiVersion = "source.toolkit.fluxcd.io/v1beta1"
    kind       = "HelmRepository"
    metadata   = { name = each.key, namespace = kubernetes_namespace.fluxcd.metadata[0].name }
    spec       = {
      interval = local.fluxcd.default_interval
      timeout  = local.fluxcd.default_timeout
      url      = each.value.repository
    }
  })

  depends_on = [kubectl_manifest.fluxcd]
}
