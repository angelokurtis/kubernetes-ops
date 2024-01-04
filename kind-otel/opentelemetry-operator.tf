resource "kubectl_manifest" "helm_repository_opentelemetry" {
  yaml_body = <<-YAML
    apiVersion: source.toolkit.fluxcd.io/v1beta2
    kind: HelmRepository
    metadata:
      name: opentelemetry
      namespace: ${kubernetes_namespace.flux.metadata[0].name}
    spec:
      interval: 60s
      url: https://open-telemetry.github.io/opentelemetry-helm-charts
  YAML

  depends_on = [kubernetes_job_v1.wait_flux_crd]
}

resource "kubectl_manifest" "helm_release_opentelemetry_operator" {
  yaml_body = <<-YAML
    apiVersion: helm.toolkit.fluxcd.io/v2beta1
    kind: HelmRelease
    metadata:
      name: opentelemetry-operator
      namespace: ${kubernetes_namespace.opentelemetry.metadata[0].name}
    spec:
      chart:
        spec:
          chart: opentelemetry-operator
          reconcileStrategy: ChartVersion
          sourceRef:
            kind: HelmRepository
            name: opentelemetry
            namespace: ${kubernetes_namespace.flux.metadata[0].name}
      interval: 60s
  YAML

  depends_on = [kubernetes_job_v1.wait_flux_crd]
}

resource "kubernetes_namespace" "opentelemetry" {
  metadata { name = "otel" }
}
