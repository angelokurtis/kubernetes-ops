resource "kubectl_manifest" "helm_repository_kubeshop" {
  yaml_body = <<-YAML
    apiVersion: source.toolkit.fluxcd.io/v1beta2
    kind: HelmRepository
    metadata:
      name: kubeshop
      namespace: ${kubernetes_namespace.flux.metadata[0].name}
    spec:
      interval: 60s
      url: https://kubeshop.github.io/helm-charts
  YAML

  depends_on = [kubernetes_job_v1.wait_flux_crd]
}

resource "kubectl_manifest" "helm_release_testkube" {
  yaml_body = <<-YAML
    apiVersion: helm.toolkit.fluxcd.io/v2beta1
    kind: HelmRelease
    metadata:
      name: testkube
      namespace: ${kubernetes_namespace.testkube.metadata[0].name}
    spec:
      chart:
        spec:
          chart: testkube
          reconcileStrategy: ChartVersion
          sourceRef:
            kind: HelmRepository
            name: kubeshop
            namespace: ${kubernetes_namespace.flux.metadata[0].name}
      valuesFrom:
        - kind: ConfigMap
          name: ${kubernetes_config_map_v1.testkube.metadata[0].name}
      interval: 60s
  YAML

  depends_on = [kubernetes_job_v1.wait_flux_crd]
}

resource "kubernetes_config_map_v1" "testkube" {
  metadata {
    name      = "testkube"
    namespace = kubernetes_namespace.testkube.metadata[0].name
  }
  data = {
    "values.yaml" = yamlencode({
      testkube-api = {
        uiIngress = {
          className = "nginx"
          enabled   = true
          path      = "/results/(v\\d/.*)"
          hosts     = ["testkube.${local.cluster_host}"]
        }
      }
      testkube-dashboard = {
        ingress = {
          className = "nginx"
          enabled   = true
          hosts     = ["testkube.${local.cluster_host}"]
        }
        apiServerEndpoint = "testkube.${local.cluster_host}"
      }
    })
  }
}

resource "kubernetes_namespace" "testkube" {
  metadata { name = "testkube" }
}
