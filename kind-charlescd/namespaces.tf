resource "kubernetes_namespace" "cd" {
  metadata { name = "cd" }
}

resource "kubernetes_namespace" "istio_system" {
  metadata {
    name = "istio-system"
    labels = { istio-injection = "disabled" }
  }
}

resource "kubernetes_namespace" "database" {
  metadata { name = "database" }
}

resource "kubernetes_namespace" "queue" {
  metadata { name = "queue" }
}
