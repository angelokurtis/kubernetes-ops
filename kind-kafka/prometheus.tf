locals {
  prometheus = {
    alertmanager           = { enabled = false }
    prometheus-pushgateway = { enabled = false }
    server                 = {
      image   = { repository = "quay.io/prometheus/prometheus", tag = "v2.42.0" }
      ingress = { enabled = true, hosts = ["prometheus.${local.cluster_host}"], ingressClassName = "haproxy" }
    }
  }
}

resource "kubernetes_namespace_v1" "prometheus" {
  metadata { name = "prometheus" }
}
