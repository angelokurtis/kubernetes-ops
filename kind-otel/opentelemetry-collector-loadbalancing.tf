resource "kubectl_manifest" "opentelemetry_collector_loadbalancing" {
  server_side_apply = true
  yaml_body         = yamlencode({
    apiVersion = "opentelemetry.io/v1alpha1"
    kind       = "OpenTelemetryCollector"
    metadata   = { name = "loadbalancing", namespace = kubernetes_namespace_v1.opentelemetry.metadata[0].name }
    spec       = {
      mode   = "deployment"
      config = file("opentelemetry-collector/loadbalancing.yaml")
    }
  })

  depends_on = [kubectl_manifest.fluxcd, kubernetes_job_v1.wait_helm_release["opentelemetry-operator"]]
}
