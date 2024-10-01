resource "kubectl_manifest" "helm_release_tempo" {
  yaml_body = <<-YAML
    apiVersion: helm.toolkit.fluxcd.io/v2beta1
    kind: HelmRelease
    metadata:
      name: tempo
      namespace: ${kubernetes_namespace.tempo.metadata[0].name}
      annotations:
        "checksum/config": ${sha256(kubernetes_config_map_v1.tempo_helm_values.data["values.yaml"])}
    spec:
      chart:
        spec:
          chart: tempo
          reconcileStrategy: ChartVersion
          sourceRef:
            kind: HelmRepository
            name: grafana
            namespace: ${kubernetes_namespace.flux.metadata[0].name}
      valuesFrom:
        - kind: ConfigMap
          name: ${kubernetes_config_map_v1.tempo_helm_values.metadata[0].name}
      interval: 60s
  YAML

  depends_on = [kubernetes_job_v1.wait_flux_crd]
}

resource "kubernetes_config_map_v1" "tempo_helm_values" {
  metadata {
    name      = "tempo-helm-values"
    namespace = kubernetes_namespace.tempo.metadata[0].name
  }
  data = {
    "values.yaml" = yamlencode({
      })
  }
}

resource "kubernetes_namespace" "tempo" {
  metadata { name = "tempo" }
}
