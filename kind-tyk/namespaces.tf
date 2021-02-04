resource "kubernetes_namespace" "tyk_ingress" {
  metadata {
    name = "tyk-ingress"
  }
}
