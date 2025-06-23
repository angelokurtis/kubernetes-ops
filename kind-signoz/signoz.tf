resource "kubectl_manifest" "helm_repository_signoz" {
  yaml_body = <<-YAML
    apiVersion: source.toolkit.fluxcd.io/v1beta2
    kind: HelmRepository
    metadata:
      name: signoz
      namespace: ${kubernetes_namespace.flux.metadata[0].name}
    spec:
      interval: 60s
      url: https://charts.signoz.io
  YAML

  depends_on = [kubernetes_job_v1.wait_flux_crd]
}


resource "kubectl_manifest" "helm_release_signoz" {
  yaml_body = <<-YAML
    apiVersion: helm.toolkit.fluxcd.io/v2beta1
    kind: HelmRelease
    metadata:
      name: signoz
      namespace: ${kubernetes_namespace.signoz.metadata[0].name}
      annotations:
        "checksum/config": ${sha256(kubernetes_config_map_v1.signoz_helm_values.data["values.yaml"])}
    spec:
      chart:
        spec:
          chart: signoz
          reconcileStrategy: ChartVersion
          sourceRef:
            kind: HelmRepository
            name: signoz
            namespace: ${kubernetes_namespace.flux.metadata[0].name}
      valuesFrom:
        - kind: ConfigMap
          name: ${kubernetes_config_map_v1.signoz_helm_values.metadata[0].name}
      interval: 60s
  YAML

  depends_on = [kubernetes_job_v1.wait_flux_crd]
}

resource "kubernetes_config_map_v1" "signoz_helm_values" {
  metadata {
    name      = "signoz-helm-values"
    namespace = kubernetes_namespace.signoz.metadata[0].name
  }
  data = {
    "values.yaml" = yamlencode({
      clickhouse = {
        installCustomStorageClass = true
      }
      global = {
        storageClass = data.kubernetes_storage_class.standard.metadata[0].name
      }
    })
  }
}

data "kubernetes_storage_class" "standard" {
  metadata { name = "standard" }
}

resource "kubernetes_namespace" "signoz" {
  metadata { name = "signoz" }
}
