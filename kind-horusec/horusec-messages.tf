resource "helm_release" "messages" {
  count = var.messages_enabled ? 1 : 0

  name = "messages"
  chart = "${var.horusec_project_path}/deployments/helm/messages"
  namespace = kubernetes_namespace.horusec.metadata[0].name
  timeout = 240
}
