locals {
  helm_repositories = {
    grafana              = { repository = "https://grafana.github.io/helm-charts" }
    haproxy-ingress      = { repository = "https://haproxy-ingress.github.io/charts" }
    jaegertracing        = { repository = "https://jaegertracing.github.io/helm-charts" }
    jetstack             = { repository = "https://charts.jetstack.io" }
    metrics-server       = { repository = "https://kubernetes-sigs.github.io/metrics-server/" }
    opentelemetry        = { repository = "https://open-telemetry.github.io/opentelemetry-helm-charts" }
    prometheus-community = { repository = "https://prometheus-community.github.io/helm-charts" }
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
