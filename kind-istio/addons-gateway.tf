locals {
  addons_gateway = {
    name = "addons",
    hosts = [
      local.kiali.host,
      local.grafana.host,
      local.tracing.host,
      local.prometheus.host
    ]
  }
  kiali = { host = "kiali.${var.ingress_domain}" }
  grafana = { host = "grafana.${var.ingress_domain}" }
  tracing = { host = "tracing.${var.ingress_domain}" }
  prometheus = { host = "prometheus.${var.ingress_domain}" }
}

resource "kustomization_resource" "addons_gateway" {
  manifest = jsonencode({
    "apiVersion" = "networking.istio.io/v1alpha3"
    "kind" = "Gateway"
    "metadata" = {
      "name" = local.addons_gateway.name
      "namespace" = kubernetes_namespace.istio_system.metadata[0].name
    }
    "spec" = {
      "selector" = { "istio" = "ingressgateway" }
      "servers" = [
        {
          hosts = local.addons_gateway.hosts
          port = { "name" = "http", "number" = 80, "protocol" = "HTTP" }
        },
      ]
    }
  })

  depends_on = [
    kustomization_resource.istio
  ]
}
