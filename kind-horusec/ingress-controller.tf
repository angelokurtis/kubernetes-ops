resource "helm_release" "ingress_controller" {
  name = "ingress-nginx"
  chart = "https://github.com/kubernetes/ingress-nginx/releases/download/helm-chart-3.22.0/ingress-nginx-3.22.0.tgz"
  namespace = kubernetes_namespace.controller.metadata[0].name
  timeout = 240

  values = [
    yamlencode({
      "controller" = {
        "extraArgs" = { "publish-status-address": "localhost" }
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
