locals {
  jaeger = {
    allInOne = {
      enabled = true
      image   = "jaegertracing/all-in-one"
      tag     = "1.37.0"
      ingress = { enabled = false }
    }

    collector = { enabled = false }
    agent     = { enabled = false }
    query     = { enabled = false }

    provisionDataStore = {
      cassandra     = false
      elasticsearch = false
      kafka         = false
    }
  }
}

resource "kubernetes_ingress_v1" "jaeger" {
  metadata {
    name      = "jaeger"
    namespace = kubernetes_namespace_v1.jaeger.metadata[0].name
  }
  spec {
    ingress_class_name = "nginx"
    rule {
      host = "jaeger.${local.cluster_host}"
      http {
        path {
          path = "/"
          backend {
            service {
              name = "jaeger-query"
              port {
                name = "http-query"
              }
            }
          }
        }
      }
    }
  }
}

resource "kubernetes_namespace_v1" "jaeger" {
  metadata { name = "jaeger" }
}
