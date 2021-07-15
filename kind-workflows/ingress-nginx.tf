resource "helm_release" "ingress_nginx" {
  name = "ingress-nginx"
  namespace = kubernetes_namespace.ingress.metadata[0].name

  repository = "https://kubernetes.github.io/ingress-nginx"
  chart = "ingress-nginx"
  version = "3.34.0"

  values = [
    yamlencode({
      "controller" = {
        "extraArgs" = { "publish-status-address": "127.0.0.1" }
        "publishService" = { "enabled" = false }
        "service" = { "type" = "NodePort" }
        "hostPort" = {
          "enabled" = true
          "ports" = { "http" = 80, "https" = 443 }
        }
        "nodeSelector" = { "ingress-ready" = "true", "kubernetes.io/os" = "linux" }
      }
    })
  ]
}

resource "kubernetes_namespace" "ingress" {
  metadata {
    name = "ingress"
  }
}
