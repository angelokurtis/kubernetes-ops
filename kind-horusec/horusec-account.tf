resource "helm_release" "account" {
  name = "account"
  // TODO use a proper repository
  chart = "${var.horusec_project_path}/horusec-account/deployments/helm/horusec-account"
  namespace = kubernetes_namespace.horusec.metadata[0].name
  timeout = 240

  values = [
    yamlencode({
      "fullnameOverride" = "account"
      "env" = [
        { name = "HORUSEC_PORT", value = "8003" },
        { name = "HORUSEC_SWAGGER_HOST", value = "0.0.0.0" },
        { name = "HORUSEC_MANAGER_URL", value = "http://horus-dev.zup.com.br" },
        { name = "HORUSEC_BROKER_HOST", value = "${helm_release.rabbit.name}.${helm_release.rabbit.namespace}" },
        { name = "HORUSEC_BROKER_PORT", value = "5672" },
        { name = "HORUSEC_DATABASE_SQL_LOG_MODE", value = "false" },
        { name = "HORUSEC_DATABASE_SQL_DIALECT", value = "postgres" },
        { name = "HORUSEC_DISABLED_BROKER", value = "true" },
        { name = "HORUSEC_GRPC_AUTH_URL", value = "auth.horusec.svc.cluster.local:8007" },
        { name = "HORUSEC_GRPC_USE_CERTS", value = "false" },
      ]
      "envFromSecret" = [
        { key = "broker-username", name = "HORUSEC_BROKER_USERNAME" },
        { key = "broker-password", name = "HORUSEC_BROKER_PASSWORD" },
        { key = "database-uri", name = "HORUSEC_DATABASE_SQL_URI" },
        { key = "jwt-token", name = "HORUSEC_JWT_SECRET_KEY" },
      ]
      "image" = { "pullPolicy" = "Always", "repository" = "horuszup/horusec-account", "tag" = "v1.0.1" }
      "ingress" = { "enabled" = true, "hosts" = [ { host = "account-horus-dev.zup.com.br", paths = [ "/" ] } ] }
      "replicaCount" = 1
      "service" = { "port" = 8003, "targetPort" = 8003, "type" = "ClusterIP" }
      "serviceAccount" = { "create" = true }
    })
  ]
}
