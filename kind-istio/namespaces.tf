resource "kubernetes_namespace" "istio_system" {
  metadata {
    name = "istio-system"
    labels = {
      istio-injection = "disabled"
    }
  }
}

resource "kubernetes_namespace" "local" {
  metadata {
    name = "local"
    labels = {
      istio-injection = "enabled"
    }
  }
}
