resource "helm_release" "flux" {
  repository       = "https://fluxcd-community.github.io/helm-charts"
  chart            = "flux2"
  name             = "flux"
  namespace        = kubernetes_namespace.flux.metadata[0].name
  create_namespace = true
}

resource "kubernetes_namespace" "flux" {
  metadata { name = "flux" }
}
