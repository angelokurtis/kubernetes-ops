resource "kubectl_manifest" "helm_repository_grafana" {
  yaml_body = <<-YAML
    apiVersion: source.toolkit.fluxcd.io/v1beta2
    kind: HelmRepository
    metadata:
      name: grafana
      namespace: ${kubernetes_namespace.flux.metadata[0].name}
    spec:
      interval: 60s
      url: https://grafana.github.io/helm-charts
  YAML

  depends_on = [kubernetes_job_v1.wait_flux_crd]
}

resource "kubectl_manifest" "helm_release_grafana" {
  yaml_body = <<-YAML
    apiVersion: helm.toolkit.fluxcd.io/v2beta1
    kind: HelmRelease
    metadata:
      name: grafana
      namespace: ${kubernetes_namespace.grafana.metadata[0].name}
      annotations:
        "checksum/config": ${sha256(kubernetes_config_map_v1.grafana_helm_values.data["values.yaml"])}
    spec:
      chart:
        spec:
          chart: grafana
          reconcileStrategy: ChartVersion
          sourceRef:
            kind: HelmRepository
            name: grafana
            namespace: ${kubernetes_namespace.flux.metadata[0].name}
      valuesFrom:
        - kind: ConfigMap
          name: ${kubernetes_config_map_v1.grafana_helm_values.metadata[0].name}
      interval: 60s
  YAML

  depends_on = [kubernetes_job_v1.wait_flux_crd]
}

resource "kubernetes_config_map_v1" "grafana_helm_values" {
  metadata {
    name      = "grafana-helm-values"
    namespace = kubernetes_namespace.grafana.metadata[0].name
  }
  data = {
    "values.yaml" = yamlencode({
      image         = { repository = "grafana/grafana", tag = "10.2.3" }
      ingress       = { enabled = true, hosts = ["grafana.${local.cluster_host}"], ingressClassName = "nginx" }
      admin         = { existingSecret = kubernetes_secret_v1.grafana_credentials.metadata[0].name }
      "grafana.ini" = {
        "auth.anonymous" = {
          enabled  = true
          org_name = "Main Org."
          org_role = "Viewer"
        }
      }
      datasources = {
        "datasources.yaml" = {
          apiVersion  = 1
          datasources = [
            {
              name      = "Prometheus"
              type      = "prometheus"
              url       = "http://prometheus-server.${kubernetes_namespace.prometheus.metadata[0].name}:80"
              access    = "proxy"
              isDefault = true
            }
          ]
        }
      }
      dashboardProviders = {
        "dashboardproviders.yaml" = {
          apiVersion = 1
          providers  = [
            {
              disableDeletion = false
              editable        = true
              folder          = ""
              name            = "default"
              options         = { path = "/var/lib/grafana/dashboards/default" }
              orgId           = 1
              type            = "file"
            },
          ]
        }
      }
      dashboardsConfigMaps = { default = kubernetes_config_map_v1.grafana_dashboards.metadata[0].name }
    })
  }
}

resource "kubernetes_secret_v1" "grafana_credentials" {
  metadata {
    name      = "grafana-credentials"
    namespace = kubernetes_namespace.grafana.metadata[0].name
  }
  data = {
    admin-user     = "admin"
    admin-password = "admin"
  }
}

resource "kubernetes_config_map_v1" "grafana_dashboards" {
  metadata {
    name      = "grafana-dashboards"
    namespace = kubernetes_namespace.grafana.metadata[0].name
  }
  binary_data = {
    "kubernetes-pod-metrics.json" = filebase64("dashboards/kubernetes-pod-metrics.json")
  }
}

resource "kubernetes_namespace" "grafana" {
  metadata { name = "grafana" }
}
