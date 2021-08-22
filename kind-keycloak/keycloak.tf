locals {
  keycloak = {
    host = "keycloak.lvh.me"
    admin = {
      user = "admin"
      password = "admin"
    }
  }
}

resource "helm_release" "keycloak" {
  name = "keycloak"
  namespace = kubernetes_namespace.iam.metadata[0].name

  repository = "https://charts.bitnami.com/bitnami"
  chart = "keycloak"
  version = "3.1.1"

  set {
    name = "nameOverride"
    value = "keycloak"
  }

  values = [
    yamlencode({
      auth = {
        adminUser = local.keycloak.admin.user
        adminPassword = local.keycloak.admin.password
      }
      ingress = { enabled = true, hostname = local.keycloak.host }
      service = { type = "ClusterIP" }
      extraEnvVars = [
        { name = "KEYCLOAK_LOGLEVEL", value = "DEBUG" },
        { name = "ROOT_LOGLEVEL", value = "DEBUG" }
      ]
      postgresql = { enabled = false }
      externalDatabase = { existingSecret = kubernetes_secret.database_env_vars.metadata[0].name }
    })
  ]

  depends_on = [ helm_release.postgresql ]
}

resource "kubernetes_secret" "database_env_vars" {
  metadata {
    name = "database-env-vars"
    namespace = kubernetes_namespace.iam.metadata[0].name
  }
  data = {
    KEYCLOAK_DATABASE_PASSWORD = local.postgresql.keycloak.password
    KEYCLOAK_DATABASE_HOST = "postgresql.${kubernetes_namespace.database.metadata[0].name}.svc.cluster.local"
    KEYCLOAK_DATABASE_PORT = 5432
    KEYCLOAK_DATABASE_NAME = local.postgresql.keycloak.database
    KEYCLOAK_DATABASE_USER = local.postgresql.keycloak.user
  }
}

resource "kubernetes_namespace" "iam" {
  metadata { name = "iam" }
}
