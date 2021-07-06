resource "kubernetes_namespace" "tracing" {
  count = var.jaeger_enabled ? 1 : 0

  metadata {
    name = "tracing"
  }
}

resource "helm_release" "jaeger_operator" {
  count = var.jaeger_enabled ? 1 : 0

  name = "jaeger-operator"
  namespace = kubernetes_namespace.tracing[0].metadata[0].name

  repository = "https://jaegertracing.github.io/helm-charts"
  chart = "jaeger-operator"
  version = "2.22.0"
}

resource "kustomization_resource" "jaeger_custom_resource" {
  count = var.jaeger_enabled ? 1 : 0

  manifest = jsonencode({
    apiVersion = "jaegertracing.io/v1"
    kind = "Jaeger"
    metadata = {
      name = "jaeger"
      namespace = kubernetes_namespace.tracing[0].metadata[0].name
    }
    spec = {
      ingress = { enabled = true, hosts = [ "tracing.zup" ] }
    }
  })

  depends_on = [
    helm_release.jaeger_operator
  ]
}
