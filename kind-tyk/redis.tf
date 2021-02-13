resource "helm_release" "tyk_redis" {
  name = "tyk-redis"
  chart = "https://charts.bitnami.com/bitnami/redis-12.7.4.tgz"
  namespace = kubernetes_namespace.database.metadata[0].name
  timeout = 120

  set {
    name = "password"
    value = var.redis_pass
  }
}