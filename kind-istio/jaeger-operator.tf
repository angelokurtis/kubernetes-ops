resource "kubernetes_namespace" "tracing" {
  metadata {
    name = "tracing"
  }
}

resource "helm_release" "jaeger_operator" {
  name = "jaeger-operator"
  namespace = kubernetes_namespace.tracing.metadata[0].name

  repository = "https://jaegertracing.github.io/helm-charts"
  chart = "jaeger-operator"
  version = "2.19.1"
}

resource "kustomization_resource" "jaeger_custom_resource" {
  manifest = jsonencode({
    apiVersion = "jaegertracing.io/v1"
    kind = "Jaeger"
    metadata = {
      name = "jaeger"
      namespace = kubernetes_namespace.tracing.metadata[0].name
    }
    spec = {
      ingress = { enabled = false }
    }
  })

  depends_on = [
    helm_release.jaeger_operator
  ]
}

