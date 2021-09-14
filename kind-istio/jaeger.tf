resource "helm_release" "jaeger_operator" {
  count = var.addons.tracing.enabled ? 1 : 0

  name = "jaeger-operator"
  namespace = kubernetes_namespace.istio_system.metadata[0].name

  repository = "https://jaegertracing.github.io/helm-charts"
  chart = "jaeger-operator"
  version = "2.24.0"
}

resource "kustomization_resource" "jaeger" {
  count = var.addons.tracing.enabled ? 1 : 0

  manifest = jsonencode({
    apiVersion = "jaegertracing.io/v1"
    kind = "Jaeger"
    metadata = {
      name = "jaeger"
      namespace = kubernetes_namespace.istio_system.metadata[0].name
    }
    spec = {
      ingress = { enabled = false }
    }
  })

  depends_on = [
    helm_release.jaeger_operator
  ]
}

resource "kustomization_resource" "jaeger_virtual_service" {
  count = var.addons.tracing.enabled ? 1 : 0

  manifest = jsonencode({
    "apiVersion" = "networking.istio.io/v1alpha3"
    "kind" = "VirtualService"
    "metadata" = {
      "name" = "jaeger-ui"
      "namespace" = kubernetes_namespace.istio_system.metadata[0].name
    }
    "spec" = {
      "gateways" = [ local.addons_gateway.name ]
      "hosts" = [ local.tracing.host ]
      "http" = [ {
          route = [ {
              destination = {
                "host" = "jaeger-query.${kubernetes_namespace.istio_system.metadata[0].name}.svc.cluster.local"
                "port" = { "number" = 16686 }
              }
          } ]
      } ]
    }
  })

  depends_on = [
    kustomization_resource.jaeger,
    kustomization_resource.addons_gateway,
  ]
}