locals {
  prometheus = {
    nodeExporter     = { enabled = true }
    kubeStateMetrics = { enabled = true }
    pushgateway      = { enabled = false }
    alertmanager     = { enabled = false }
    configmapReload  = {
      prometheus = { image = { repository = "jimmidyson/configmap-reload", tag = "v0.7.1" } }
    }
    server = {
      image      = { repository = "quay.io/prometheus/prometheus", tag = "v2.38.0" }
      extraFlags = ["web.enable-remote-write-receiver"]
      ingress    = { enabled = true, hosts = ["prometheus.${local.cluster_host}"], ingressClassName = "nginx" }
    }
  }
}

resource "kubernetes_namespace_v1" "prometheus" {
  metadata { name = "prometheus" }
}
