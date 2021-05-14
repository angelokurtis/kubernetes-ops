resource "helm_release" "analytic" {
  count = var.analytic_enabled ? 1 : 0

  name = "analytic"
  chart = "${var.horusec_project_path}/deployments/helm/analytic"
  namespace = kubernetes_namespace.horusec.metadata[0].name
  timeout = 240

  values = [
    yamlencode({
      image = {
        tag = "local"
        pullPolicy = "Never"
      }
    })
  ]
}
