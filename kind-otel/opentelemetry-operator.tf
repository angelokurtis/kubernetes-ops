locals {
  opentelemetry_operator = {
    manager = {
      image = {
        repository = "ghcr.io/open-telemetry/opentelemetry-operator/opentelemetry-operator"
        tag        = "0.59.0"
      }
    }
  }
}

resource "kubernetes_namespace_v1" "opentelemetry" {
  metadata {
    name   = "otel"
    labels = {
      "goldilocks.fairwinds.com/enabled" = true
    }
  }
}
