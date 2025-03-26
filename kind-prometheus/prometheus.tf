resource "kubectl_manifest" "helm_repository_prometheus_community" {
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

resource "kubectl_manifest" "helm_release_kube_prometheus_stack" {
  yaml_body = <<-YAML
    apiVersion: helm.toolkit.fluxcd.io/v2beta1
    kind: HelmRelease
    metadata:
      name: kube-prometheus-stack
      namespace: ${kubernetes_namespace.prometheus.metadata[0].name}
      annotations:
        "checksum/config": ${sha256(kubernetes_config_map_v1.kube_prometheus_stack_helm_values.data["values.yaml"])}
    spec:
      chart:
        spec:
          chart: kube-prometheus-stack
          reconcileStrategy: ChartVersion
          sourceRef:
            kind: HelmRepository
            name: prometheus-community
            namespace: ${kubernetes_namespace.flux.metadata[0].name}
      valuesFrom:
        - kind: ConfigMap
          name: ${kubernetes_config_map_v1.kube_prometheus_stack_helm_values.metadata[0].name}
      interval: 60s
  YAML

  depends_on = [kubernetes_job_v1.wait_flux_crd]
}

resource "kubernetes_config_map_v1" "kube_prometheus_stack_helm_values" {
  metadata {
    name      = "kube-prometheus-stack-helm-values"
    namespace = kubernetes_namespace.prometheus.metadata[0].name
  }
  data = {
    "values.yaml" = yamlencode({
      prometheus = {
        ingress = {
          enabled          = true
          ingressClassName = "nginx"
          hosts = ["prometheus.${local.cluster_host}"]
        }
      }
      alertmanager = {
        ingress = {
          enabled          = true
          ingressClassName = "nginx"
          hosts = ["alertmanager.${local.cluster_host}"]
        }
      }
    })
  }
}

resource "kubernetes_secret_v1" "alertmanager_slack_secret" {
  metadata {
    name      = "alertmanager-slack"
    namespace = kubernetes_namespace.prometheus.metadata[0].name
  }
  binary_data = {
    slack_api_url = base64encode(var.slack_webhook_url)
  }
}

resource "kubernetes_namespace" "prometheus" {
  metadata { name = var.prometheus_namespace }
}
