resource "helm_release" "mongodb" {
  name = "horusec-mongodb"
  chart = "https://charts.bitnami.com/bitnami/mongodb-10.6.2.tgz"
  namespace = kubernetes_namespace.database.metadata[0].name
  timeout = 240

  values = [
    yamlencode({
      "service" = { "labels" = { "app" = "mongodb" } }
      "podLabels" = { "app" = "mongodb" }
      "auth" = {
        "username" = var.mongodb_user
        "password" = var.mongodb_pass
        "database" = "horusec_db"
      }
    })
  ]
}
