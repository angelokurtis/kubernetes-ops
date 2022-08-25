locals {
  nginx = {
    namespace       = kubernetes_namespace_v1.nginx.metadata[0].name
    chart           = "ingress-nginx"
    helm_repository = kubectl_manifest.helm_repository["ingress-nginx"]
    values          = {
      controller = {
        extraArgs      = { publish-status-address = "127.0.0.1" }
        hostPort       = { enabled = true, ports = { http = 80, https = 443 } }
        nodeSelector   = { "ingress-ready" = "true", "kubernetes.io/os" = "linux" }
        publishService = { enabled = false }
        service        = { type = "NodePort" }
      }
    }
  }
}

resource "kubernetes_namespace_v1" "nginx" {
  metadata { name = "nginx" }
}
