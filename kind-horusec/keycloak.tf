resource "kubernetes_namespace" "iam" {
  count = var.keycloak_enabled ? 1 : 0

  metadata {
    name = "iam"
  }
}

resource "helm_release" "keycloak" {
  count = var.keycloak_enabled ? 1 : 0

  name = "keycloak"
  namespace = kubernetes_namespace.iam[0].metadata[0].name

  repository = "https://charts.bitnami.com/bitnami"
  chart = "keycloak"
  version = "3.1.1"

  values = [
    yamlencode({
      auth = {
        adminUser = "admin"
        adminPassword = "admin"
      }
      ingress = { enabled = true, hostname = "keycloak.lvh.me" }
      service = { type = "ClusterIP" }
      extraEnvVars = [
        { name = "KEYCLOAK_LOGLEVEL", value = "DEBUG" },
        { name = "ROOT_LOGLEVEL", value = "DEBUG" }
      ]
    })
  ]
}
