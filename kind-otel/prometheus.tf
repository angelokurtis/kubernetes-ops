locals {
  prometheus = {
    nodeExporter = {
      enabled = true
      image   = { repository = "quay.io/prometheus/node-exporter", tag = "v1.4.0" }
    }
    kubeStateMetrics   = { enabled = true }
    kube-state-metrics = {
      image = { repository = "registry.k8s.io/kube-state-metrics/kube-state-metrics", tag = "v2.6.0" }
    }
    pushgateway     = { enabled = false }
    alertmanager    = { enabled = false }
    configmapReload = {
      prometheus = { image = { repository = "jimmidyson/configmap-reload", tag = "v0.8.0" } }
    }
    server = {
      image      = { repository = "quay.io/prometheus/prometheus", tag = "v2.39.1" }
      extraFlags = ["web.enable-remote-write-receiver"]
      ingress    = { enabled = true, hosts = ["prometheus.${local.cluster_host}"], ingressClassName = "nginx" }
    }
  }
}

resource "kubernetes_namespace_v1" "prometheus" {
  metadata { name = "prometheus" }
}
