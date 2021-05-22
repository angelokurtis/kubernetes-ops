resource "kubernetes_namespace" "iam" {
  metadata {
    name = "iam"
  }
}

resource "helm_release" "keycloak" {
  name = "keycloak"
  namespace = kubernetes_namespace.iam.metadata[0].name

  repository = "https://charts.bitnami.com/bitnami"
  chart = "keycloak"
  version = "3.0.2"

  values = [
    yamlencode({
      auth = {
        adminUser = "admin"
        adminPassword = "admin"
      }
      ingress = { enabled = true, hostname = "keycloak.apicurio.local" }
      service = { type = "ClusterIP" }
      extraEnvVars = [
        { name = "KEYCLOAK_LOGLEVEL", value = "DEBUG" },
        { name = "ROOT_LOGLEVEL", value = "DEBUG" }
      ]
    })
  ]
}
