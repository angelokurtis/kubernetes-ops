resource "kubectl_manifest" "helm_repository_openfga" {
  yaml_body = <<-YAML
    apiVersion: source.toolkit.fluxcd.io/v1
    kind: HelmRepository
    metadata:
      name: openfga
      namespace: ${kubernetes_namespace_v1.flux.metadata[0].name}
    spec:
      interval: 60s
      url: https://openfga.github.io/helm-charts
  YAML

  wait_for {
    condition {
      type   = "Ready"
      status = "True"
    }
  }

  depends_on = [kubernetes_job_v1.wait_flux_crd]
}
