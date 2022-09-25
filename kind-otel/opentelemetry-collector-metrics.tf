resource "kubectl_manifest" "opentelemetry_collector_metrics" {
  server_side_apply = true
  yaml_body         = yamlencode({
    apiVersion = "opentelemetry.io/v1alpha1"
    kind       = "OpenTelemetryCollector"
    metadata   = { name = "metrics", namespace = kubernetes_namespace_v1.opentelemetry.metadata[0].name }
    spec       = {
      config   = file("opentelemetry-collector/metrics.yaml")
      mode     = "deployment"
      replicas = 3
      env      = [
        {
          name  = "PROMETHEUS_PUSHGATEWAY_ENDPOINT",
          value = "prometheus-server.${kubernetes_namespace_v1.prometheus.metadata[0].name}.svc.cluster.local:80"
        },
      ]
    }
  })

  depends_on = [kubectl_manifest.fluxcd, kubernetes_job_v1.wait_helm_release["opentelemetry-operator"]]
}
