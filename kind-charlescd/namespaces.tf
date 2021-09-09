resource "kubernetes_namespace" "cd" {
  metadata { name = "cd" }
}
