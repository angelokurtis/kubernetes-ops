locals {
  jaeger = {
    namespace = "tracing"
    query     = { host = "jaeger.lvh.me" }
    collector = { host = "jaeger-collector.lvh.me" }
  }
}

resource "kubernetes_namespace" "tracing" {
  metadata { name = local.jaeger.namespace }
}

resource "helm_release" "jaeger_operator" {
  name      = "jaeger-operator"
  namespace = kubernetes_namespace.tracing.metadata[0].name

  repository = "https://jaegertracing.github.io/helm-charts"
  chart      = "jaeger-operator"
  version    = "2.27.1"

  set {
    name  = "fullnameOverride"
    value = "simplest"
  }

  values = [
    yamlencode({
      image  = { repository = "jaegertracing/jaeger-operator", tag = "1.29.1" }
      jaeger = {
        create = true
        spec   = {
          ingress  = {
            enabled          = true
            hosts            = [local.jaeger.query.host]
            ingressClassName = "nginx"
          }
          storage  = { type = "memory" }
          strategy = "allinone"
        }
      }
    })
  ]
}

resource "kubernetes_ingress" "jaeger_collector" {
  metadata {
    name      = "jaeger-collector"
    namespace = kubernetes_namespace.tracing.metadata[0].name
  }
  spec {
    ingress_class_name = "nginx"
    rule {
      host = local.jaeger.collector.host
      http {
        path {
          backend {
            service_name = "simplest-jaeger-collector"
            service_port = "14268"
          }
        }
      }
    }
  }

  depends_on = [helm_release.jaeger_operator]
}
