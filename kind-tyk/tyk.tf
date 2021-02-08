resource "helm_release" "tyk" {
  name = "tyk"
  chart = "${path.root}/charts/tyk-gateway"
  version = "1.0.0"
  namespace = kubernetes_namespace.gateway.metadata[0].name
  timeout = 240

  values = [
    yamlencode({
      "service" = { "type" = "NodePort" }
      "hostPort" = { "enabled" = true }
      "nodeSelector" = { "ingress-ready" = "true" }
    })
  ]

  depends_on = [
    helm_release.tyk_redis
  ]
}
