resource "kubernetes_namespace" "cd" {
  metadata { name = "cd" }
}

resource "kubernetes_namespace" "istio_system" {
  metadata {
    name = "istio-system"
    labels = { istio-injection = "disabled" }
  }
}
