resource "helm_release" "jaeger_operator" {
  name = "jaeger-operator"
  namespace = kubernetes_namespace.tracing.metadata[0].name

  repository = "https://jaegertracing.github.io/helm-charts"
  chart = "jaeger-operator"
  version = "2.22.0"
}

resource "kubernetes_namespace" "tracing" {
  metadata {
    name = "tracing"
  }
}
