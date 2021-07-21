resource "helm_release" "argo_workflows" {
  name = "argo-workflows"
  namespace = kubernetes_namespace.argo.metadata[0].name

  repository = "https://argoproj.github.io/argo-helm"
  chart = "argo-workflows"
  version = "0.2.7"

  values = [
    yamlencode({
      controller: {
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
        ingress = { enabled = true, hosts = [ "argocd.127.0.1.1.nip.io" ] }
      }
    })
  ]
}

resource "kubernetes_secret" "argo_postgres_config" {
  metadata {
    name = "argo-postgres-config"
    namespace = kubernetes_namespace.argo.metadata[0].name
  }
  data = {
    username = "postgres"
    password = data.kubernetes_secret.postgresql.data.postgresql-password
  }
}

resource "kubernetes_namespace" "argo" {
  metadata { name = "argo" }
}
