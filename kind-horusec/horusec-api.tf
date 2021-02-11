resource "helm_release" "horusec_api" {
  count = var.api_enabled ? 1 : 0

  name = "horusec-api"
  // TODO use a proper repository
  chart = "${var.horusec_project_path}/horusec-api/deployments/helm/horusec-api"
  namespace = kubernetes_namespace.horusec.metadata[0].name
  timeout = 240

  values = [
    yamlencode({
      "env" = [
        { name = "HORUSEC_SWAGGER_HOST", value = "0.0.0.0" },
        { name = "HORUSEC_BROKER_HOST", value = "${helm_release.rabbit.name}.${helm_release.rabbit.namespace}" },
        { name = "HORUSEC_BROKER_PORT", value = "5672" },
        { name = "HORUSEC_PORT", value = "8000" },
        { name = "HORUSEC_DATABASE_SQL_LOG_MODE", value = "true" },
        { name = "HORUSEC_DATABASE_SQL_DIALECT", value = "postgres" },
        { name = "HORUSEC_GRPC_AUTH_URL", value = "${helm_release.auth[0].name}.${helm_release.auth[0].namespace}.svc.cluster.local:8007" },
        { name = "HORUSEC_GRPC_USE_CERTS", value = "false" },
        { name = "HORUSEC_GRPC_CERT_PATH", value = "" },
        { name = "HORUSEC_DISABLED_BROKER", value = "false" },
      ]
      "envFromSecret" = [
        { key = "broker-username", name = "HORUSEC_BROKER_USERNAME" },
        { key = "broker-password", name = "HORUSEC_BROKER_PASSWORD" },
        { key = "database-uri", name = "HORUSEC_DATABASE_SQL_URI" },
        { key = "jwt-token", name = "HORUSEC_JWT_SECRET_KEY" },
      ]
      "image" = { "pullPolicy" = "Always", "repository" = "horuszup/horusec-api", "tag" = "v2.8.0" }
      "ingress" = {
        "enabled" = true
        "hosts" = [ { host = "api-horus-dev.zup.com.br", paths = [ "/" ] } ]
        "annotations" = { "kubernetes.io/ingress.class" = "nginx" }
      }
      "service" = { "port" = 8000, "targetPort" = 8000, "type" = "ClusterIP" }
      "serviceAccount" = { "create" = true }
    })
  ]

  depends_on = [
    kubernetes_secret.jwt_token,
    helm_release.rabbit,
    helm_release.postgres,
    kubernetes_secret.broker_username,
    kubernetes_secret.broker_password,
    kubernetes_secret.database_uri,
    kubernetes_secret.database_username,
    kubernetes_secret.database_password,
  ]
}
