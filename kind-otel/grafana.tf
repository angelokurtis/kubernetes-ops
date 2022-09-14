locals {
  grafana = {
    image = {
      repository = "grafana/grafana"
      tag        = "9.1.5"
    }
    ingress       = { enabled = true, hosts = ["grafana.${local.cluster_host}"], ingressClassName = "nginx" }
    "grafana.ini" = {
      "auth.anonymous" = {
        enabled  = true
        org_name = "Main Org."
        org_role = "Admin"
      }
    }
    datasources = {
      "datasources.yaml" = {
        apiVersion  = 1
        datasources = [
          {
            name      = "Prometheus"
            type      = "prometheus"
            url       = "http://prometheus-server.${kubernetes_namespace_v1.prometheus.metadata[0].name}.svc.cluster.local:80"
            access    = "proxy"
            isDefault = true
          }
        ]
      }
    }
    dashboards = {
      default = {
        vpa-recommendations = { gnetId = 14588, datasource = "prometheus" }
      }
    }
  }
}

resource "kubernetes_namespace_v1" "grafana" {
  metadata { name = "grafana" }
}
