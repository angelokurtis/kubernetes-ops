resource "helm_release" "core" {
  count = var.account_enabled ? 1 : 0

  name = "core"
  chart = "${var.horusec_project_path}/deployments/helm/core"
  namespace = kubernetes_namespace.horusec.metadata[0].name
  timeout = 240

  depends_on = [
    helm_release.auth
  ]
}
