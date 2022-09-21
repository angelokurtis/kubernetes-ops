resource "kubectl_manifest" "opentelemetry_collector_simplest" {
  server_side_apply = true
  yaml_body         = yamlencode({
    apiVersion = "opentelemetry.io/v1alpha1"
    kind       = "OpenTelemetryCollector"
    metadata   = { name = "tailsampling", namespace = kubernetes_namespace_v1.opentelemetry.metadata[0].name }
    spec       = {
      mode = "deployment"
      env  = [
        {
          name  = "JAEGER_OTLP_ENDPOINT",
          value = "jaeger-collector.${kubernetes_namespace_v1.jaeger.metadata[0].name}.svc.cluster.local:4317"
        },
      ]
      config   = file("opentelemetry-collector/tailsampling.yaml")
      replicas = 20
    }
  })

  depends_on = [kubectl_manifest.fluxcd, kubernetes_job_v1.wait_helm_release["opentelemetry-operator"]]
}
