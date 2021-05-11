resource "helm_release" "postgres" {
  name = "postgresql"
  chart = "https://charts.bitnami.com/bitnami/postgresql-10.4.3.tgz"
  namespace = kubernetes_namespace.horusec.metadata[0].name

  set {
    name = "postgresqlDatabase"
    value = "horusec_db"
  }

  set {
    name = "postgresqlPassword"
    value = "Jhea7mg0df"
  }
}
