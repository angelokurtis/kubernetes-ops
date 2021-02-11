resource "helm_release" "analytic" {
  count = var.analytic_enabled ? 1 : 0

  name = "analytic"
  // TODO use a proper repository
  chart = "${var.horusec_project_path}/horusec-analytic/deployments/helm/horusec-analytic"
  namespace = kubernetes_namespace.horusec.metadata[0].name
  timeout = 240

  values = [
    yamlencode({
      "fullnameOverride" = "analytic"
      "env" = [
        { name = "HORUSEC_SWAGGER_HOST", value = "0.0.0.0" },
        { name = "HORUSEC_PORT", value = "8005" },
        { name = "HORUSEC_DATABASE_SQL_DIALECT", value = "postgres" },
        { name = "HORUSEC_DATABASE_SQL_LOG_MODE", value = "false" },
        { name = "HORUSEC_GRPC_AUTH_URL", value = "${helm_release.auth[0].name}.${helm_release.auth[0].namespace}.svc.cluster.local:8007" },
        { name = "HORUSEC_GRPC_USE_CERTS", value = "false" },
        { name = "HORUSEC_GRPC_CERT_PATH", value = "" },
      ]
      "envFromSecret" = [
        { key = "database-uri", name = "HORUSEC_DATABASE_SQL_URI" },
        { key = "jwt-token", name = "HORUSEC_JWT_SECRET_KEY" },
      ]
      "image" = {
        "pullPolicy" = "Always"
        "repository" = "horuszup/horusec-analytic"
        "tag" = "v1.0.0"
      }
      "ingress" = {
        "enabled" = true
        "hosts" = [ { host = "analytic-horus-dev.zup.com.br", paths = [ "/" ] } ]
      }
      "replicaCount" = 1
      "service" = { "port" = 8005, "targetPort" = 8005, "type" = "ClusterIP" }
      "serviceAccount" = { "create" = true }
    })
  ]
}
