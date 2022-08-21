resource "helm_release" "flux2" {
  name      = "flux2"
  namespace = kubernetes_namespace.flux2.metadata[0].name

  repository = "https://fluxcd-community.github.io/helm-charts"
  chart      = "flux2"
  version    = "1.0.0"

  values = [
    yamlencode({
      imageautomationcontroller = { create = false }
      imagereflectorcontroller  = { create = false }
      kustomizecontroller       = { create = false }
      notificationcontroller    = { create = false }
      helmcontroller            = {
        image = "fluxcd/helm-controller"
        tag   = "v0.23.0"
      }
      sourcecontroller = {
        image = "fluxcd/source-controller"
        tag   = "v0.27.0"
      }
    })
  ]
}

resource "kubernetes_namespace" "flux2" {
  metadata { name = "flux2" }
}
