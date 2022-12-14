resource "kubectl_manifest" "opentelemetry_collector" {
  server_side_apply = true
  yaml_body         = yamlencode({
    apiVersion = "opentelemetry.io/v1alpha1"
    kind       = "OpenTelemetryCollector"
    metadata   = { name = "default", namespace = kubernetes_namespace_v1.opentelemetry.metadata[0].name }
    spec       = {
      config   = file("${path.cwd}/opentelemetry-collector.yaml")
      mode     = "deployment"
      replicas = 1
      env      = [
        {
          name  = "JAEGER_OTLP_ENDPOINT",
          value = "jaeger-collector.${kubernetes_namespace_v1.jaeger.metadata[0].name}.svc.cluster.local:4317"
        },
        {
          name  = "PROMETHEUS_PUSHGATEWAY_ENDPOINT",
          value = "prometheus-server.${kubernetes_namespace_v1.prometheus.metadata[0].name}.svc.cluster.local:80"
        },
        {
          name      = "POD_IP"
          valueFrom = { fieldRef = { fieldPath = "status.podIP" } }
        },
      ]
    }
  })

  depends_on = [kubectl_manifest.fluxcd, kubernetes_job_v1.wait_helm_release["opentelemetry-operator"]]
}

resource "kubernetes_ingress_v1" "opentelemetry_collector" {
  metadata {
    name        = "opentelemetry-collector"
    namespace   = kubernetes_namespace_v1.opentelemetry.metadata[0].name
    labels      = { app = "opentelemetry-collector" }
    annotations = { "haproxy-ingress.github.io/backend-protocol" = "grpc" }
  }
  spec {
    ingress_class_name = "haproxy"
    rule {
      host = "otel.lvh.me"
      http {
        path {
          path      = "/"
          path_type = "Prefix"

          backend {
            service {
              name = "default-collector"
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

