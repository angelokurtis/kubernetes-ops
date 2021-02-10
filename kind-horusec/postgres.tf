resource "helm_release" "postgres" {
  name = "postgresql"
  chart = "https://charts.bitnami.com/bitnami/postgresql-10.2.7.tgz"
  namespace = kubernetes_namespace.database.metadata[0].name
  timeout = 240

  values = [
    yamlencode({
      "service" = { "labels" = { "app" = "postgresql" } }
      "podLabels" = { "app" = "postgresql" }
      "postgresqlDatabase" = "horusec_db"
    })
  ]
}
