resource "kustomization_resource" "jaeger" {
  manifest = jsonencode(yamldecode(data.template_file.jaeger.rendered))

  depends_on = [
    helm_release.jaeger_operator
  ]
}

data "template_file" "jaeger" {
  template = file("${path.module}/jaeger.yaml")
  vars = {
    NAMESPACE = kubernetes_namespace.tracing.metadata[0].name
  }
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
    kustomization_resource.jaeger
  ]
}