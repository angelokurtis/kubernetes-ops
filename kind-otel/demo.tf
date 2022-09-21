resource "kubernetes_ingress_v1" "demo" {
  metadata {
    name      = "demo"
    namespace = kubernetes_namespace_v1.demo.metadata[0].name
  }
  spec {
    ingress_class_name = "nginx"
    rule {
      host = "demo.${local.cluster_host}"
      http {
        path {
          path = "/bets"
          backend {
            service {
              name = "bets"
              port {
                name = "http"
              }
            }
          }
        }
        path {
          path = "/championships"
          backend {
            service {
              name = "championships"
              port {
                name = "http"
              }
            }
          }
        }
        path {
          path = "/matches"
          backend {
            service {
              name = "matches"
              port {
                name = "http"
              }
            }
          }
        }
        path {
          path = "/teams"
          backend {
            service {
              name = "teams"
              port {
                name = "http"
              }
            }
          }
        }
      }
    }
  }
}

resource "kubernetes_namespace_v1" "demo" {
  metadata { name = "demo" }
}
