locals {
  grafana = {
    image         = { repository = "grafana/grafana", tag = "9.3.6" }
    ingress       = { enabled = true, hosts = ["grafana.${local.cluster_host}"], ingressClassName = "haproxy" }
    "grafana.ini" = {
      "auth" = {
        disable_login_form = true
      }
      "auth.anonymous" = {
        enabled      = true
        org_name     = "Main Org."
        org_role     = "Admin"
        hide_version = true
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

resource "kubernetes_config_map_v1" "grafana_dashboards" {
  metadata {
    name      = "grafana-dashboards"
    namespace = kubernetes_namespace_v1.grafana.metadata[0].name
  }
  binary_data = {
    "kminion-cluster_rev1.json" = filebase64("dashboards/kminion-cluster_rev1.json")
    "kminion-groups_rev1.json"  = filebase64("dashboards/kminion-groups_rev1.json")
    "kminion-topic_rev1.json"   = filebase64("dashboards/kminion-topic_rev1.json")
  }
}

resource "kubernetes_namespace_v1" "grafana" {
  metadata { name = "grafana" }
}
