locals {
  opentelemetry_operator = {
    manager = {
      collectorImage = { repository = "otel/opentelemetry-collector-contrib", tag = "0.68.0" }
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
