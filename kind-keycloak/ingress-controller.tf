resource "helm_release" "ingress_nginx" {
  name = "ingress-nginx"
  chart = "https://github.com/kubernetes/ingress-nginx/releases/download/helm-chart-3.24.0/ingress-nginx-3.24.0.tgz"
  namespace = kubernetes_namespace.ingress.metadata[0].name

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
