locals {
  haproxy = {
    controller = {
      hostNetwork          = true
      ingressClassResource = { enabled = true, default = true }
      service              = { type = "NodePort" }
    }
  }
}

resource "kubernetes_namespace_v1" "haproxy" {
  metadata { name = "haproxy" }
}
