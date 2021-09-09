resource "helm_release" "redis" {
  name = "redis"
  namespace = kubernetes_namespace.database.metadata[0].name

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
}

data "kubernetes_secret" "redis" {
  metadata {
    name = "redis"
    namespace = kubernetes_namespace.database.metadata[0].name
  }
}