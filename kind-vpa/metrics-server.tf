locals {
  metrics_server = {
    args = ["--kubelet-insecure-tls"]
  }
}


resource "kubernetes_namespace_v1" "metrics_server" {
  metadata { name = "metrics-server" }
}
