resource "helm_release" "tyk_redis" {
  name = "tyk-redis"
  chart = "https://charts.bitnami.com/bitnami/redis-12.6.4.tgz"
  namespace = kubernetes_namespace.tyk_ingress.metadata[0].name
  timeout = 120

  values = [
    yamlencode({
      password = var.redis_pass
    })
  ]
}