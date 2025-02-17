resource "kubectl_manifest" "helm_repository_aqua" {
  yaml_body = <<-YAML
    apiVersion: source.toolkit.fluxcd.io/v1beta2
    kind: HelmRepository
    metadata:
      name: aqua
      namespace: ${kubernetes_namespace.flux.metadata[0].name}
    spec:
      interval: 60s
      url: https://aquasecurity.github.io/helm-charts
  YAML

  depends_on = [kubernetes_job_v1.wait_flux_crd]
}

resource "kubectl_manifest" "helm_release_trivy_operator" {
  yaml_body = <<-YAML
    apiVersion: helm.toolkit.fluxcd.io/v2beta1
    kind: HelmRelease
    metadata:
      name: trivy-operator
      namespace: ${kubernetes_namespace.trivy.metadata[0].name}
      annotations:
        "checksum/config": ${sha256(kubernetes_config_map_v1.trivy_operator_helm_values.data["values.yaml"])}
    spec:
      chart:
        spec:
          chart: trivy-operator
          reconcileStrategy: ChartVersion
          sourceRef:
            kind: HelmRepository
            name: aqua
            namespace: ${kubernetes_namespace.flux.metadata[0].name}
      valuesFrom:
        - kind: ConfigMap
          name: ${kubernetes_config_map_v1.trivy_operator_helm_values.metadata[0].name}
      interval: 60s
  YAML

  depends_on = [kubernetes_job_v1.wait_flux_crd]
}

resource "kubernetes_config_map_v1" "trivy_operator_helm_values" {
  metadata {
    name      = "trivy-operator-helm-values"
    namespace = kubernetes_namespace.trivy.metadata[0].name
  }
  data = {
    "values.yaml" = yamlencode({})
  }
}

resource "kubernetes_namespace" "trivy" {
  metadata { name = "trivy" }
}
