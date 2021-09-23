resource "kubernetes_namespace" "continuous_deployment" {
  metadata { name = "continuous-deployment" }
}

resource "kubernetes_namespace" "istio_system" {
  metadata {
    name   = "istio-system"
    labels = { istio-injection = "disabled" }
  }
}

resource "kubernetes_namespace" "database" {
  metadata { name = "database" }
}

resource "kubernetes_namespace" "cache" {
  metadata { name = "cache" }
}

resource "kubernetes_namespace" "queue" {
  metadata { name = "queue" }
}
