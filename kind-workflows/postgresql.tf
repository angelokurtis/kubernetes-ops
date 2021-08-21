resource "helm_release" "postgresql" {
  name = "postgresql"
  namespace = kubernetes_namespace.database.metadata[0].name

  repository = "https://charts.bitnami.com/bitnami"
  chart = "postgresql"
  version = "10.9.3"

  set {
    name = "nameOverride"
    value = "postgresql"
  }
}

resource "kubernetes_namespace" "database" {
  metadata { name = "database" }
}

data "kubernetes_secret" "postgresql" {
  metadata {
    name = "postgresql"
    namespace = kubernetes_namespace.database.metadata[0].name
  }

  depends_on = [ helm_release.postgresql ]
}