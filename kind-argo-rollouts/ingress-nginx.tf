locals {
  ingress_nginx = {
    name        = "ingress-nginx"
    destination = {
      namespace = kubernetes_namespace.ingress_controller.metadata[0].name
      server    = "https://kubernetes.default.svc"
    }
    source = {
      chart          = "ingress-nginx"
      repoURL        = "https://kubernetes.github.io/ingress-nginx"
      targetRevision = "4.x.x"
      helm           = {
        values = yamlencode({
          controller = {
            extraArgs      = { publish-status-address = local.ingress_ip }
            hostPort       = { enabled = true, ports = { http = 80, https = 443 } }
            nodeSelector   = { ingress-ready = "true", "kubernetes.io/os" = "linux" }
            publishService = { enabled = false }
            service        = { type = "NodePort" }
          }
        })
      }
    }
  }
}

resource "kubernetes_namespace" "ingress_controller" {
  metadata { name = "ingress-controller" }
}
