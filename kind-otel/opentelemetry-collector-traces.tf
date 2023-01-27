resource "kubectl_manifest" "opentelemetry_collector_traces" {
  server_side_apply = true
  yaml_body         = yamlencode({
    apiVersion = "opentelemetry.io/v1alpha1"
    kind       = "OpenTelemetryCollector"
    metadata   = { name = "traces", namespace = kubernetes_namespace_v1.opentelemetry.metadata[0].name }
    spec       = {
      config   = file("${path.cwd}/opentelemetry-collector-traces.yaml")
      mode     = "deployment"
      replicas = 1
      env      = [
        {
          name  = "RESOLVER_DNS_HOSTNAME",
          value = "${kubectl_manifest.opentelemetry_collector_traces_backend.name}-collector-headless.${kubectl_manifest.opentelemetry_collector_traces_backend.namespace}"
        },
      ]
      podAnnotations = { "prometheus.io/scrape" = "true", "prometheus.io/port" = "8888" }
      serviceAccount = "otelcol-traces"
    }
  })

  depends_on = [kubectl_manifest.fluxcd, kubernetes_job_v1.wait_helm_release["opentelemetry-operator"]]
}

resource "kubernetes_ingress_v1" "opentelemetry_collector_traces" {
  metadata {
    name        = "opentelemetry-collector-traces"
    namespace   = kubernetes_namespace_v1.opentelemetry.metadata[0].name
    labels      = { app = "opentelemetry-collector-traces" }
    annotations = { "haproxy-ingress.github.io/backend-protocol" = "grpc" }
  }
  spec {
    ingress_class_name = "haproxy"
    rule {
      host = "traces.otel.lvh.me"
      http {
        path {
          path      = "/"
          path_type = "Prefix"

          backend {
            service {
              name = "${kubectl_manifest.opentelemetry_collector_traces.name}-collector"
              port {
                number = 4317
              }
            }
          }
        }
      }
    }
  }
}
