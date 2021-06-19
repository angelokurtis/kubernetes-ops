resource "helm_release" "jaeger_operator" {
  name = "jaeger-operator"
  namespace = kubernetes_namespace.tracing.metadata[0].name

  repository = "https://jaegertracing.github.io/helm-charts"
  chart = "jaeger-operator"
  version = "2.21.4"
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
      ingress = { enabled = true, hosts = [ "tracing.local" ] }
    }
  })

  depends_on = [
    helm_release.jaeger_operator
  ]
}

resource "kubernetes_ingress" "jaeger_collector" {
  metadata {
    name = "jaeger-collector"
    namespace = kubernetes_namespace.tracing.metadata[0].name
  }
  spec {
    rule {
      host = "collector.local"
      http {
        path {
          backend {
            service_name = "jaeger-collector"
            service_port = "14268"
          }
        }
      }
    }
  }

  depends_on = [
    kustomization_resource.jaeger_custom_resource
  ]
}

resource "kubernetes_namespace" "tracing" {
  metadata {
    name = "tracing"
  }
}
