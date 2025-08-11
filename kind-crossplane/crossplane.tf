resource "kubectl_manifest" "helm_repository_crossplane" {
  yaml_body = <<-YAML
    apiVersion: source.toolkit.fluxcd.io/v1beta2
    kind: HelmRepository
    metadata:
      name: crossplane
      namespace: ${kubernetes_namespace.flux.metadata[0].name}
    spec:
      interval: 60s
      url: https://charts.crossplane.io/stable
  YAML

  depends_on = [kubernetes_job_v1.wait_flux_crd]
}


resource "kubectl_manifest" "helm_release_crossplane" {
  yaml_body = <<-YAML
    apiVersion: helm.toolkit.fluxcd.io/v2beta1
    kind: HelmRelease
    metadata:
      name: crossplane
      namespace: ${kubernetes_namespace.crossplane.metadata[0].name}
      annotations:
        "checksum/config": ${sha256(kubernetes_config_map_v1.crossplane_helm_values.data["values.yaml"])}
    spec:
      chart:
        spec:
          chart: crossplane
          version: ^2.0.0
          reconcileStrategy: ChartVersion
          sourceRef:
            kind: HelmRepository
            name: crossplane
            namespace: ${kubernetes_namespace.flux.metadata[0].name}
      valuesFrom:
        - kind: ConfigMap
          name: ${kubernetes_config_map_v1.crossplane_helm_values.metadata[0].name}
      interval: 60s
  YAML

  depends_on = [kubernetes_job_v1.wait_flux_crd]
}

resource "kubernetes_config_map_v1" "crossplane_helm_values" {
  metadata {
    name      = "crossplane-helm-values"
    namespace = kubernetes_namespace.crossplane.metadata[0].name
  }
  data = {
    "values.yaml" = yamlencode({

    })
  }
}

resource "kubernetes_namespace" "crossplane" {
  metadata { name = "crossplane" }
}
