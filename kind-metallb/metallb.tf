locals {
  metallb = {
    namespace       = kubernetes_namespace_v1.metallb.metadata[0].name
    helm_repository = "bitnami"
  }
}

resource "kubernetes_namespace_v1" "metallb" {
  metadata { name = "metallb" }
}
