resource "kubectl_manifest" "opentelemetry_collector_default" {
  server_side_apply = true
  yaml_body         = yamlencode({
    apiVersion = "opentelemetry.io/v1alpha1"
    kind       = "OpenTelemetryCollector"
    metadata   = { name = "default", namespace = kubernetes_namespace_v1.opentelemetry.metadata[0].name }
    spec       = {
      mode     = "statefulset"
      replicas = 1
      ports    = [{ name = "prometheus", port = 8889, targetPort = 8889 }]
      env      = [
        {
          name  = "JAEGER_OTLP_ENDPOINT",
          value = "jaeger-collector.${kubernetes_namespace_v1.jaeger.metadata[0].name}.svc.cluster.local:4317"
        },
        {
          name  = "PROMETHEUS_PUSHGATEWAY_ENDPOINT",
          value = "prometheus-server.${kubernetes_namespace_v1.prometheus.metadata[0].name}.svc.cluster.local:80"
        },
      ]
      config = file("opentelemetry-collector/default.yaml")
    }
  })

  depends_on = [kubectl_manifest.fluxcd, kubernetes_job_v1.wait_helm_release["opentelemetry-operator"]]
}
