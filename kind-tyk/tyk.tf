resource "helm_release" "tyk" {
  name = "tyk"
  chart = "${path.root}/charts/tyk-gateway"
  version = "1.0.2"
  namespace = kubernetes_namespace.gateway.metadata[0].name
  timeout = 240

  values = [
    yamlencode({
      "hostPort" = { "enabled" = false }
      "config" = jsondecode(file("./tyk.json"))
    })
  ]

  depends_on = [
    helm_release.tyk_redis
  ]
}
