locals {
  opentelemetry_operator = {
    manager = {
      image = {
        repository = "ghcr.io/open-telemetry/opentelemetry-operator/opentelemetry-operator"
        tag        = "0.58.0"
      }
    }
  }
}

resource "kubernetes_namespace_v1" "opentelemetry" {
  metadata { name = "otel" }
}
