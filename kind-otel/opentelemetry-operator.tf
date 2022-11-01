locals {
  opentelemetry_operator = {
    manager = {
      collectorImage = { repository = "otel/opentelemetry-collector-contrib" }
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
