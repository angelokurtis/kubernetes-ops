resource "helm_release" "ingress_nginx" {
  name      = "ingress-nginx"
  namespace = kubernetes_namespace.ingress_controller.metadata[0].name

  repository = "https://kubernetes.github.io/ingress-nginx"
  chart      = "ingress-nginx"
  version    = "4.0.13"

  values = [
    yamlencode({
      controller = {
        extraArgs      = { publish-status-address = "127.0.0.1" }
        hostPort       = { enabled = true, ports = { http = 80, https = 443 } }
        nodeSelector   = { ingress-ready = "true", "kubernetes.io/os" = "linux" }
        publishService = { enabled = false }
        service        = { type = "NodePort" }
      }
    })
  ]
}

resource "kubernetes_namespace" "ingress_controller" {
  metadata { name = "ingress-controller" }
}
