resource "kubectl_manifest" "opentelemetry_collector_traces_backend" {
  server_side_apply = true
  yaml_body         = yamlencode({
    apiVersion = "opentelemetry.io/v1alpha1"
    kind       = "OpenTelemetryCollector"
    metadata   = { name = "traces-backend", namespace = kubernetes_namespace_v1.opentelemetry.metadata[0].name }
    spec       = {
      config   = file("${path.cwd}/opentelemetry-collector-traces-backend.yaml")
      mode     = "deployment"
      replicas = 3
      env      = [
        {
          name  = "JAEGER_OTLP_ENDPOINT",
          value = "jaeger-collector.${kubernetes_namespace_v1.jaeger.metadata[0].name}.svc.cluster.local:4317"
        },
        {
          name  = "SPANMETRICS_OTLP_ENDPOINT"
          value = "${kubectl_manifest.opentelemetry_collector_metrics.name}-collector.${kubectl_manifest.opentelemetry_collector_metrics.namespace}.svc.cluster.local:4317"
        },
      ]
      ports          = [{ name = "spanmetrics", port = 9090 }]
      podAnnotations = { "prometheus.io/scrape" = "true", "prometheus.io/port" = "9090" }
    }
  })

  depends_on = [kubectl_manifest.fluxcd, kubernetes_job_v1.wait_helm_release["opentelemetry-operator"]]
}
