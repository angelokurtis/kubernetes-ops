resource "helm_release" "redis" {
  name = "redis"
  namespace = kubernetes_namespace.cache.metadata[0].name

  repository = "https://charts.bitnami.com/bitnami"
  chart = "redis"
  version = "15.3.2"

  set {
    name = "nameOverride"
    value = "redis"
  }

  set {
    name = "architecture"
    value = "standalone"
  }

  set {
    name = "auth.existingSecret"
    value = kubernetes_secret.redis.metadata[0].name
  }

  set {
    name = "auth.existingSecretPasswordKey"
    value = "password"
  }
}

resource "random_password" "redis" {
  length = 16
}

resource "kubernetes_secret" "redis" {
  metadata {
    name = "redis"
    namespace = kubernetes_namespace.cache.metadata[0].name
  }
  data = {
    password = random_password.redis.result
  }
}
