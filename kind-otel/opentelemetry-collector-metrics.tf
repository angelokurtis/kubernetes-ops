resource "kubectl_manifest" "opentelemetry_collector_metrics" {
  server_side_apply = true
  yaml_body         = yamlencode({
    apiVersion = "opentelemetry.io/v1alpha1"
    kind       = "OpenTelemetryCollector"
    metadata   = { name = "metrics", namespace = kubernetes_namespace_v1.opentelemetry.metadata[0].name }
    spec       = {
      config   = file("${path.cwd}/opentelemetry-collector-metrics.yaml")
      mode     = "deployment"
      replicas = 3
      env      = [
        {
          name  = "PROMETHEUS_PUSHGATEWAY_ENDPOINT",
          value = "prometheus-server.${kubernetes_namespace_v1.prometheus.metadata[0].name}:80"
        },
      ]
      podAnnotations = { "prometheus.io/scrape" = "true", "prometheus.io/port" = "8888" }
    }
  })

  depends_on = [kubectl_manifest.fluxcd, kubernetes_job_v1.wait_helm_release["opentelemetry-operator"]]
}
