locals {
  kminion = {
    podDisruptionBudget = null
    podAnnotations      = {
      "prometheus.io/scrape" = "true"
      "prometheus.io/port"   = "8080"
      "prometheus.io/path"   = "/metrics"
    }
    kminion = {
      config = {
        kafka = {
          brokers = ["single-kafka-brokers.${kubernetes_namespace_v1.kafka.metadata[0].name}"]
        }
      }
    }
  }
}

resource "kubernetes_namespace_v1" "kminion" {
  metadata { name = "kminion" }
}
