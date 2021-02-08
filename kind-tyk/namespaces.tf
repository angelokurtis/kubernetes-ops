resource "kubernetes_namespace" "gateway" {
  metadata {
    name = "gateway"
  }
}

resource "kubernetes_namespace" "database" {
  metadata {
    name = "database"
  }
}
