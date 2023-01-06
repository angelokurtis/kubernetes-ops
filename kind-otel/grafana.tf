locals {
  grafana = {
    image         = { repository = "grafana/grafana", tag = "9.3.2" }
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
            url       = "http://prometheus-server.${kubernetes_namespace_v1.prometheus.metadata[0].name}:80"
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
  }
}

resource "kubernetes_secret_v1" "grafana_credentials" {
  metadata {
    name      = "grafana-credentials"
    namespace = kubernetes_namespace_v1.grafana.metadata[0].name
  }
  data = {
    admin-user     = "admin"
    admin-password = "admin"
  }
}

resource "kubernetes_config_map_v1" "grafana_dashboards" {
  metadata {
    name      = "grafana-dashboards"
    namespace = kubernetes_namespace_v1.grafana.metadata[0].name
  }
  binary_data = {
    "kubernetes-pod-metrics.json" = filebase64("dashboards/kubernetes-pod-metrics.json")
  }
}

resource "kubernetes_namespace_v1" "grafana" {
  metadata { name = "grafana" }
}
