locals {
  keycloak = {
    version = "15.0.2"
    host    = "keycloak.${local.cluster_domain}"
  }
}

resource "helm_release" "keycloak" {
  name      = "keycloak"
  namespace = kubernetes_namespace.iam.metadata[0].name

  repository = "https://charts.bitnami.com/bitnami"
  chart      = "keycloak"
  version    = "5.0.7"

  set {
    name  = "nameOverride"
    value = "keycloak"
  }

  values = [
    yamlencode({
      image            = { repository = "bitnami/keycloak", tag = local.keycloak.version }
      auth             = {
        adminUser                 = "admin"
        existingSecretPerPassword = {
          adminPassword      = { name = kubernetes_secret.keycloak_passwords.metadata[0].name }
          managementPassword = { name = kubernetes_secret.keycloak_passwords.metadata[0].name }
          databasePassword   = { name = kubernetes_secret.keycloak_passwords.metadata[0].name }
        }
      }
      ingress          = {
        enabled     = true
        hostname    = local.keycloak.host
        pathType    = "Prefix"
        annotations = {
          "kubernetes.io/ingress.class" = "istio"
        }
      }
      service          = { type = "ClusterIP" }
      extraEnvVars     = [
        { name = "KEYCLOAK_LOGLEVEL", value = "DEBUG" },
        { name = "ROOT_LOGLEVEL", value = "DEBUG" }
      ]
      postgresql       = { enabled = false }
      externalDatabase = { existingSecret = kubernetes_secret.database_env_vars.metadata[0].name }
    })
  ]

  depends_on = [helm_release.postgresql]
}

resource "random_password" "keycloak_admin" {
  length = 16
}

resource "random_password" "keycloak_management" {
  length = 16
}

resource "kubernetes_secret" "keycloak_passwords" {
  metadata {
    name      = "keycloak-passwords"
    namespace = kubernetes_namespace.iam.metadata[0].name
  }
  data = {
    adminPassword      = random_password.keycloak_admin.result
    managementPassword = random_password.keycloak_management.result
    databasePassword   = local.database["keycloak"]["password"]
  }
}

resource "kubernetes_secret" "database_env_vars" {
  metadata {
    name      = "database-env-vars"
    namespace = kubernetes_namespace.iam.metadata[0].name
  }
  data = {
    KEYCLOAK_DATABASE_HOST = "postgresql.${kubernetes_namespace.database.metadata[0].name}.svc.cluster.local"
    KEYCLOAK_DATABASE_PORT = 5432
    KEYCLOAK_DATABASE_NAME = local.database["keycloak"]["database"]
    KEYCLOAK_DATABASE_USER = local.database["keycloak"]["user"]
  }
}

resource "kubernetes_namespace" "iam" {
  metadata { name = "iam" }
}
