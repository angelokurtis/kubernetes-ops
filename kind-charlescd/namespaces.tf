resource "kubernetes_namespace" "continuous_deployment" {
  metadata { name = "continuous-deployment" }
}

resource "kubernetes_namespace" "cache" {
  metadata { name = "cache" }
}
