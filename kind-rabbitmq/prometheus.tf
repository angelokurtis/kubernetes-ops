resource "kubectl_manifest" "helm_repository_prometheus" {
  yaml_body = <<-YAML
    apiVersion: source.toolkit.fluxcd.io/v1beta2
    kind: HelmRepository
    metadata:
      name: prometheus-community
      namespace: ${kubernetes_namespace.flux.metadata[0].name}
    spec:
      interval: 60s
      url: https://prometheus-community.github.io/helm-charts
  YAML

  depends_on = [kubernetes_job_v1.wait_flux_crd]
}

resource "kubectl_manifest" "helm_release_prometheus" {
  yaml_body = <<-YAML
    apiVersion: helm.toolkit.fluxcd.io/v2beta1
    kind: HelmRelease
    metadata:
      name: prometheus
      namespace: ${kubernetes_namespace_v1.prometheus.metadata[0].name}
    spec:
      chart:
        spec:
          chart: prometheus
          reconcileStrategy: ChartVersion
          sourceRef:
            kind: HelmRepository
            name: prometheus-community
            namespace: ${kubernetes_namespace.flux.metadata[0].name}
      valuesFrom:
        - kind: ConfigMap
          name: ${kubernetes_config_map_v1.prometheus_values.metadata[0].name}
      interval: 60s
  YAML

  depends_on = [kubernetes_job_v1.wait_flux_crd]
}

resource "kubernetes_config_map_v1" "prometheus_values" {
  metadata {
    name      = "prometheus-values"
    namespace = kubernetes_namespace_v1.prometheus.metadata[0].name
  }
  data = {
    "values.yaml" = yamlencode({
      prometheus-node-exporter = { enabled = false }
      kube-state-metrics       = { enabled = false }
      prometheus-pushgateway   = { enabled = false }
      alertmanager             = { enabled = false }
      server                   = {
        ingress = {
          enabled          = true
          hosts            = ["prometheus.${local.cluster_host}"]
          ingressClassName = "nginx"
        }
      }
    })
  }
}

resource "kubernetes_namespace_v1" "prometheus" {
  metadata { name = "prometheus" }
}

