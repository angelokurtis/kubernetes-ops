resource "kubectl_manifest" "helm_repository_bitnami" {
  yaml_body = <<YAML
    apiVersion: source.toolkit.fluxcd.io/v1beta1
    kind: HelmRepository
    metadata:
      name: bitnami
      namespace: ${kubernetes_namespace.flux.metadata[0].name}
    spec:
      interval: 60s
      url: https://charts.bitnami.com/bitnami
  YAML

  depends_on = [kubernetes_job_v1.wait_flux_crd]
}
