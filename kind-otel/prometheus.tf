locals {
  prometheus = {
    nodeExporter     = { enabled = false }
    kubeStateMetrics = { enabled = false }
    pushgateway      = { enabled = false }
    alertmanager     = { enabled = false }
    serverFiles      = { "prometheus.yml" = { scrape_configs = [] } }
    configmapReload  = { prometheus = { image = { repository = "jimmidyson/configmap-reload", tag = "v0.8.0" } } }
    server           = {
      image      = { repository = "quay.io/prometheus/prometheus", tag = "v2.40.1" }
      extraFlags = ["web.enable-remote-write-receiver"]
      ingress    = { enabled = true, hosts = ["prometheus.${local.cluster_host}"], ingressClassName = "nginx" }
    }
  }
}

resource "kubernetes_namespace_v1" "prometheus" {
  metadata { name = "prometheus" }
}
