locals {
  vertical_pod_autoscaler = {
    admissionController = {
      extraArgs = { v = "2", vpa-object-namespace = kubernetes_namespace_v1.opentelemetry.metadata[0].name }
    }
    recommender = {
      extraArgs = { v = "2", vpa-object-namespace = kubernetes_namespace_v1.opentelemetry.metadata[0].name }
    }
    updater = { enabled = false }
  }
}

resource "kubernetes_namespace_v1" "vertical_pod_autoscaler" {
  metadata { name = "vertical-pod-autoscaler" }
}
