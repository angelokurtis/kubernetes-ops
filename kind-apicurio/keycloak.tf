locals {
  keycloak = {
    host = "keycloak.lvh.me"
    admin = { user = "admin", password = "admin" }
  }
}

resource "helm_release" "keycloak" {
  name = "keycloak"
  namespace = kubernetes_namespace.iam.metadata[0].name

  repository = "https://charts.bitnami.com/bitnami"
  chart = "keycloak"
  version = "5.0.5"

  set {
    name = "nameOverride"
    value = "keycloak"
  }

  values = [
    yamlencode({
      image = { repository = "bitnami/keycloak", tag = "15.0.2" }
      auth = {
        adminUser = local.keycloak.admin.user
        existingSecretPerPassword = {
          adminPassword = { name = kubernetes_secret.keycloak_passwords.metadata[0].name }
          managementPassword = { name = kubernetes_secret.keycloak_passwords.metadata[0].name }
          databasePassword = { name = kubernetes_secret.keycloak_passwords.metadata[0].name }
        }
      }
      ingress = { enabled = true, ingressClassName = "nginx", hostname = local.keycloak.host }
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

resource "random_password" "keycloak_management" {
  length = 16
  special = true
}

resource "kubernetes_secret" "keycloak_passwords" {
  metadata {
    name = "keycloak-passwords"
    namespace = kubernetes_namespace.iam.metadata[0].name
  }
  data = {
    adminPassword = local.keycloak.admin.password
    managementPassword = random_password.keycloak_management.result
    databasePassword = local.postgresql.keycloak.password
  }
}

resource "kubernetes_secret" "database_env_vars" {
  metadata {
    name = "database-env-vars"
    namespace = kubernetes_namespace.iam.metadata[0].name
  }
  data = {
    KEYCLOAK_DATABASE_HOST = "postgresql.${kubernetes_namespace.database.metadata[0].name}.svc.cluster.local"
    KEYCLOAK_DATABASE_PORT = 5432
    KEYCLOAK_DATABASE_NAME = local.postgresql.keycloak.database
    KEYCLOAK_DATABASE_USER = local.postgresql.keycloak.user
  }
}

resource "kubernetes_namespace" "iam" {
  metadata { name = "iam" }
}
