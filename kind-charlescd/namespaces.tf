resource "kubernetes_namespace" "continuous_deployment" {
  metadata { name = "continuous-deployment" }
}
