resource "kubernetes_namespace" "jaeger" {
  metadata { name = "jaeger" }
}

resource "helm_release" "jaeger_operator" {
  name      = "jaeger-operator"
  namespace = kubernetes_namespace.jaeger.metadata[0].name

  repository = "https://jaegertracing.github.io/helm-charts"
  chart      = "jaeger-operator"
  version    = "2.28.0"

  values = [
    <<YAML
    fullnameOverride: simplest
    jaeger:
      create: true
      spec:
        ingress:
          enabled: true
          hosts:
          - jaeger.lvh.me
          ingressClassName: nginx
        storage:
          type: memory
        strategy: allinone
    YAML
  ]
}

resource "kubernetes_ingress_v1" "jaeger_collector" {
  wait_for_load_balancer = true
  metadata {
    name      = "jaeger-collector"
    namespace = kubernetes_namespace.jaeger.metadata[0].name
  }
  spec {
    ingress_class_name = "nginx"
    rule {
      host = "jaeger-collector.lvh.me"
      http {
        path {
          backend {
            service {
              name = "simplest-jaeger-collector"
              port {
                number = 14268
              }
            }
          }
        }
      }
    }
  }

  depends_on = [
    helm_release.jaeger_operator,
    helm_release.ingress_nginx
  ]
}
