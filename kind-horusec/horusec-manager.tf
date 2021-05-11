resource "helm_release" "manager" {
  count = var.manager_enabled ? 1 : 0

  name = "manager"
  chart = "${var.horusec_project_path}/deployments/helm/manager"
  namespace = kubernetes_namespace.horusec.metadata[0].name
  timeout = 240
}
