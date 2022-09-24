locals {
  vertical_pod_autoscaler = {
    recommender = {
      extraArgs = { v = "2", vpa-object-namespace = kubernetes_namespace_v1.opentelemetry.metadata[0].name }
    }
    admissionController = { enabled = false }
    updater             = { enabled = false }
  }
}

resource "kubernetes_namespace_v1" "vertical_pod_autoscaler" {
  metadata { name = "vertical-pod-autoscaler" }
}
