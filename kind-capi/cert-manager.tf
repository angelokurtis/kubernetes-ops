resource "kubectl_manifest" "helm_repository_jetstack" {
  yaml_body = <<-YAML
    apiVersion: source.toolkit.fluxcd.io/v1beta2
    kind: HelmRepository
    metadata:
      name: jetstack
      namespace: ${kubernetes_namespace.flux.metadata[0].name}
    spec:
      interval: 60s
      url: https://charts.jetstack.io
  YAML

  depends_on = [kubernetes_job_v1.wait_flux_crd]
}

resource "kubectl_manifest" "helm_release_cert_manager" {
  yaml_body = <<-YAML
    apiVersion: helm.toolkit.fluxcd.io/v2beta1
    kind: HelmRelease
    metadata:
      name: cert-manager
      namespace: ${kubernetes_namespace.cert_manager.metadata[0].name}
      annotations:
        "checksum/config": ${sha256(kubernetes_config_map_v1.cert_manager_helm_values.data["values.yaml"])}
    spec:
      chart:
        spec:
          chart: cert-manager
          reconcileStrategy: ChartVersion
          sourceRef:
            kind: HelmRepository
            name: jetstack
            namespace: ${kubernetes_namespace.flux.metadata[0].name}
      valuesFrom:
        - kind: ConfigMap
          name: ${kubernetes_config_map_v1.cert_manager_helm_values.metadata[0].name}
      interval: 60s
  YAML

  depends_on = [kubernetes_job_v1.wait_flux_crd]
}

resource "kubernetes_config_map_v1" "cert_manager_helm_values" {
  metadata {
    name      = "cert-manager-helm-values"
    namespace = kubernetes_namespace.cert_manager.metadata[0].name
  }
  data = {
    "values.yaml" = yamlencode({
      installCRDs = true
      prometheus  = { enabled = false }
    })
  }
}

resource "kubernetes_namespace" "cert_manager" {
  metadata { name = "cert-manager" }
}
