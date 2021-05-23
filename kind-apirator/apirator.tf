resource "kubernetes_namespace" "apirator_system" {
  metadata {
    name = "apirator-system"
  }
}
