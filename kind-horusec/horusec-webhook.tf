resource "helm_release" "webhook" {
  count = var.webhook_enabled ? 1 : 0

  name = "webhook"
  chart = "${var.horusec_project_path}/deployments/helm/webhook"
  namespace = kubernetes_namespace.horusec.metadata[0].name
  timeout = 240
}
