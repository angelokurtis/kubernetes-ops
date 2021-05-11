resource "helm_release" "api" {
  count = var.api_enabled ? 1 : 0

  name = "api"
  chart = "${var.horusec_project_path}/deployments/helm/api"
  namespace = kubernetes_namespace.horusec.metadata[0].name
  timeout = 240

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
