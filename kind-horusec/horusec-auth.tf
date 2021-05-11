resource "helm_release" "auth" {
  count = var.auth_enabled ? 1 : 0

  name = "auth"
  chart = "${var.horusec_project_path}/deployments/helm/auth"
  namespace = kubernetes_namespace.horusec.metadata[0].name
  timeout = 240

  depends_on = [
    helm_release.postgres,
    helm_release.rabbit
  ]
}
