locals {
  cert_manager = {
    installCRDs = true
    prometheus  = { enabled = false }
  }
}

resource "kubernetes_namespace_v1" "cert_manager" {
  metadata { name = "cert-manager" }
}
