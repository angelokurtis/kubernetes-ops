resource "kubernetes_namespace" "tracing" {
  metadata {
    name = "tracing"
  }
}

resource "helm_release" "jaeger_operator" {
  name = "jaeger-operator"
  chart = "https://github.com/jaegertracing/helm-charts/releases/download/jaeger-operator-2.19.1/jaeger-operator-2.19.1.tgz"
  namespace = kubernetes_namespace.tracing.metadata[0].name
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

