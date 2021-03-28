resource "helm_release" "prometheus" {
  count = var.addons.prometheus.enabled ? 1 : 0

  name = "prometheus"
  namespace = kubernetes_namespace.istio_system.metadata[0].name

  repository = "https://prometheus-community.github.io/helm-charts"
  chart = "prometheus"
  version = "13.6.0"

  values = [
    yamlencode({
      "alertmanager" = { "enabled" = false }
      "kubeStateMetrics" = { "enabled" = false }
      "nodeExporter" = { "enabled" = false }
      "pushgateway" = { "enabled" = false }
      "server" = {
        "fullnameOverride" = "prometheus"
        "global" = { "scrape_interval" = "15s" }
        "persistentVolume" = { "enabled" = false }
        "podAnnotations" = { "sidecar.istio.io/inject" = "false" }
        "readinessProbeInitialDelay" = 0
        "service" = { "servicePort" = 9090 }
      }
    })
  ]

  depends_on = [
    kustomization_resource.istio
  ]
}

resource "kustomization_resource" "prometheus_virtual_service" {
  count = var.addons.prometheus.enabled ? 1 : 0

  manifest = jsonencode({
    "apiVersion" = "networking.istio.io/v1alpha3"
    "kind" = "VirtualService"
    "metadata" = {
      "name" = "prometheus-ui"
      "namespace" = kubernetes_namespace.istio_system.metadata[0].name
    }
    "spec" = {
      "gateways" = [ local.addons_gateway.name ]
      "hosts" = [ local.prometheus.host ]
      "http" = [ {
          route = [ {
              destination = {
                "host" = "prometheus.${kubernetes_namespace.istio_system.metadata[0].name}.svc.cluster.local"
                "port" = { "number" = 9090 }
              }
          } ]
      } ]
    }
  })

  depends_on = [
    helm_release.prometheus,
    kustomization_resource.addons_gateway,
  ]
}
