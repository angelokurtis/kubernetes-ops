resource "helm_release" "postgres_analytic" {
  name = "postgres-analytic"
  chart = "https://charts.bitnami.com/bitnami/postgresql-10.4.3.tgz"
  namespace = kubernetes_namespace.analytic_db.metadata[0].name

  set {
    name = "postgresqlDatabase"
    value = "analytic_db"
  }

  set {
    name = "postgresqlPassword"
    value = "4dffe5f19a27"
  }
}

resource "kubernetes_namespace" "analytic_db" {
  metadata {
    name = "analytic-db"
  }
}

data "kubernetes_secret" "analytic_db" {
  metadata {
    name = "postgres-analytic-postgresql"
    namespace = kubernetes_namespace.analytic_db.metadata[0].name
  }

  depends_on = [
    helm_release.postgres_analytic
  ]
}

resource "kubernetes_secret" "analytic-db" {
  metadata {
    name = "analytic-db"
    namespace = kubernetes_namespace.horusec.metadata[0].name
  }
  data = {
    postgresql-username = "postgres"
    postgresql-password = data.kubernetes_secret.analytic_db.data.postgresql-password
  }
}