resource "helm_release" "postgres_platform" {
  name = "postgres-platform"
  chart = "https://charts.bitnami.com/bitnami/postgresql-10.4.3.tgz"
  namespace = kubernetes_namespace.platform_db.metadata[0].name

  set {
    name = "postgresqlDatabase"
    value = "horusec_db"
  }

  set {
    name = "postgresqlPassword"
    value = "ada875581dfb"
  }
}

resource "kubernetes_namespace" "platform_db" {
  metadata {
    name = "platform-db"
  }
}

data "kubernetes_secret" "platform_db" {
  metadata {
    name = "postgres-platform-postgresql"
    namespace = kubernetes_namespace.platform_db.metadata[0].name
  }

  depends_on = [
    helm_release.postgres_platform
  ]
}

resource "kubernetes_secret" "platform_db" {
  metadata {
    name = "platform-db"
    namespace = kubernetes_namespace.horusec.metadata[0].name
  }
  data = {
    postgresql-username = "postgres"
    postgresql-password = data.kubernetes_secret.platform_db.data.postgresql-password
  }
}