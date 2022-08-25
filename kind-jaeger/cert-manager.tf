locals {
  cert-manager = {
    namespace       = kubernetes_namespace_v1.cert_manager.metadata[0].name
    chart           = "cert-manager"
    helm_repository = kubectl_manifest.helm_repository["jetstack"]
    values          = {
      installCRDs = true
      prometheus  = { enabled = false }
    }
  }
}

resource "kubernetes_namespace_v1" "cert_manager" {
  metadata { name = "cert-manager" }
}
