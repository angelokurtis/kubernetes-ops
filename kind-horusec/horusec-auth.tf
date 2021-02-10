resource "helm_release" "auth" {
  name = "auth"
  // TODO use a proper repository
  chart = "${var.horusec_project_path}/horusec-auth/deployments/helm/horusec-auth"
  namespace = kubernetes_namespace.horusec.metadata[0].name
  timeout = 240

  values = [
    yamlencode({
      "fullnameOverride" = "auth"
      "env" = [
        { name = "HORUSEC_SWAGGER_HOST", value = "0.0.0.0" },
        { name = "HORUSEC_PORT", value = "8006" },
        { name = "HORUSEC_DATABASE_SQL_DIALECT", value = "postgres" },
        { name = "HORUSEC_DATABASE_SQL_LOG_MODE", value = "false" },
        { name = "HORUSEC_API_URL", value = "" },
        { name = "HORUSEC_GRPC_PORT", value = "8007" },
        { name = "HORUSEC_GRPC_USE_CERTS", value = "false" },
        { name = "HORUSEC_BROKER_HOST", value = "${helm_release.rabbit.name}.${helm_release.rabbit.namespace}" },
        { name = "HORUSEC_BROKER_PORT", value = "5672" },
        { name = "HORUSEC_DISABLED_BROKER", value = "false" },
        { name = "HORUSEC_AUTH_TYPE", value = "horusec" },
        { name = "HORUSEC_ENABLE_APPLICATION_ADMIN", value = "false" },
        {
          name = "HORUSEC_APPLICATION_ADMIN_DATA",
          value = "{\\\"username\\\":\\\"horusec-admin\\\",\\\"email\\\":\\\"horusec-admin@example.com\\\",\\\"password\\\":\\\"Devpass0*\\\"}"
        },
      ]
      "envFromSecret" = [
        { key = "broker-username", name = "HORUSEC_BROKER_USERNAME" },
        { key = "broker-password", name = "HORUSEC_BROKER_PASSWORD" },
        { key = "database-uri", name = "HORUSEC_DATABASE_SQL_URI" },
        { key = "jwt-token", name = "HORUSEC_JWT_SECRET_KEY" },
      ]
      "image" = { "pullPolicy" = "Always", "repository" = "horuszup/horusec-auth", "tag" = "latest" }
      "ingress" = {
        "enabled" = true
        "hosts" = [ { host = "auth-horus-dev.zup.com.br", paths = [ "/" ] } ]
      }
      "replicaCount" = 1
      "service" = { "port" = 8006, "targetPort" = 8006, "type" = "ClusterIP" }
      "serviceAccount" = { "create" = true }
    })
  ]

  depends_on = [
    helm_release.postgres,
    helm_release.rabbit
  ]
}
