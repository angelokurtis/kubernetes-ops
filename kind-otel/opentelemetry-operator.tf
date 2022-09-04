locals {
  opentelemetry_operator = {
    namespace       = kubernetes_namespace_v1.opentelemetry.metadata[0].name
    helm_repository = "opentelemetry"
    values          = {
      manager = {
        image = {
          repository = "ghcr.io/open-telemetry/opentelemetry-operator/opentelemetry-operator"
          tag        = "0.58.0"
        }
      }
    }
    dependsOn = [{ name = "cert-manager", namespace = kubernetes_namespace_v1.cert_manager.metadata[0].name }]
  }
}

resource "kubernetes_namespace_v1" "opentelemetry" {
  metadata { name = "otel" }
}
