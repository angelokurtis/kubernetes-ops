resource "kubectl_manifest" "helm_repository_jaeger" {
  yaml_body = <<-YAML
    apiVersion: source.toolkit.fluxcd.io/v1
    kind: HelmRepository
    metadata:
      name: jaegertracing
      namespace: ${kubernetes_namespace_v1.flux.metadata[0].name}
    spec:
      interval: 60s
      url: https://jaegertracing.github.io/helm-charts
  YAML

  depends_on = [kubernetes_job_v1.wait_flux_crd]
}

resource "kubectl_manifest" "helm_release_jaeger" {
  yaml_body = <<-YAML
    apiVersion: helm.toolkit.fluxcd.io/v2
    kind: HelmRelease
    metadata:
      name: jaeger
      namespace: ${kubernetes_namespace_v1.jaeger.metadata[0].name}
      annotations:
        "checksum/config": ${sha256(kubernetes_config_map_v1.jaeger_helm_values.data["values.yaml"])}
    spec:
      chart:
        spec:
          chart: jaeger
          sourceRef:
            kind: HelmRepository
            name: jaegertracing
            namespace: ${kubernetes_namespace_v1.flux.metadata[0].name}
      valuesFrom:
        - kind: ConfigMap
          name: ${kubernetes_config_map_v1.jaeger_helm_values.metadata[0].name}
      interval: 60s
  YAML

  depends_on = [kubernetes_job_v1.wait_flux_crd]
}

resource "kubernetes_config_map_v1" "jaeger_helm_values" {
  metadata {
    name      = "jaeger-helm-values"
    namespace = kubernetes_namespace_v1.jaeger.metadata[0].name
  }
  data = {
    "values.yaml" = yamlencode({
      tag = local.jaeger_latest_release
    })
  }
}

data "external" "jaeger_latest_release" {
  program = ["python3", "${path.module}/get_latest_github_release_version.py"]

  query = {
    repo = "jaegertracing/jaeger"
  }
}

locals {
  jaeger_latest_release = data.external.jaeger_latest_release.result["normalized_tag"]
}

resource "kubernetes_namespace_v1" "jaeger" {
  metadata { name = "jaeger" }
}
