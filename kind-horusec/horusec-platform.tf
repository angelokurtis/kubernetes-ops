resource "helm_release" "horusec_platform" {
  name = "horusec-platform"
  chart = "${var.horusec_project_path}/deployments/helm/horusec-platform"
  namespace = kubernetes_namespace.horusec.metadata[0].name
  timeout = 60

  values = [
    yamlencode({
      global = {
        jwt = {
          secretKeyRef = { key = "jwt-token", name = "jwt-token" }
        }
        broker = {
          host = "rabbitmq.${kubernetes_namespace.horusec.metadata[0].name}"
          user = { secretKeyRef = { key = "broker-username", name = "broker-username" } }
          password = { secretKeyRef = { key = "rabbitmq-password", name = "rabbitmq" } }
        }
        database = {
          host = "postgres-platform-postgresql.${kubernetes_namespace.platform_db.metadata[0].name}"
          user = { secretKeyRef = { key = "postgresql-username", name = "platform-db" } }
          password = { secretKeyRef = { key = "postgresql-password", name = "platform-db" } }
        }
      }
      components = {
        analytic = {
          database = {
            host = "postgres-analytic-postgresql.${kubernetes_namespace.analytic_db.metadata[0].name}"
            user = { secretKeyRef = { key = "postgresql-username", name = "analytic-db" } }
            password = { secretKeyRef = { key = "postgresql-password", name = "analytic-db" } }
          }
        }
      }
    })
  ]
}
