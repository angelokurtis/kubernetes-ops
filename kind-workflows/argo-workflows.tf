locals {
  argo_workflows = { version = "v3.1.8" }
}

resource "helm_release" "argo_workflows" {
  name = "argo-workflows"
  namespace = kubernetes_namespace.workflows.metadata[0].name

  repository = "https://argoproj.github.io/argo-helm"
  chart = "argo-workflows"
  version = "0.4.1"

  set {
    name = "nameOverride"
    value = "argo-workflows"
  }

  values = [
    yamlencode({
      executor = { image = { tag = local.argo_workflows.version } }
      server = { image = { tag = local.argo_workflows.version } }
      controller: {
        image = { tag = local.argo_workflows.version }
        persistence: {
          archive = true
          archiveTTL = "7d"
          connectionPool = { connMaxLifetime = "0s", maxIdleConns = 100, maxOpenConns = 0 }
          nodeStatusOffLoad = true
          postgresql = {
            database = "postgres"
            host = "postgresql.${kubernetes_namespace.database.metadata[0].name}.svc.cluster.local"
            passwordSecret = { key = "password", name = kubernetes_secret.argo_postgres_config.metadata[0].name }
            port = 5432
            tableName = "argo_workflows"
            userNameSecret = { key = "username", name = kubernetes_secret.argo_postgres_config.metadata[0].name }
          }
        }
      }
      server = {
        ingress = { enabled = true, hosts = [ "argo-workflows.lvh.me" ] }
      }
    })
  ]
}

resource "kubernetes_secret" "argo_postgres_config" {
  metadata {
    name = "argo-postgres-config"
    namespace = kubernetes_namespace.workflows.metadata[0].name
  }
  data = {
    username = "postgres"
    password = data.kubernetes_secret.postgresql.data.postgresql-password
  }
}

resource "kubernetes_namespace" "workflows" {
  metadata { name = "workflows" }
}
