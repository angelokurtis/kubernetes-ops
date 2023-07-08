resource "helm_release" "fluxcd" {
  repository       = "https://fluxcd-community.github.io/helm-charts"
  chart            = "flux2"
  name             = "fluxcd"
  namespace        = kubernetes_namespace.fluxcd.metadata[0].name
  create_namespace = true
}


resource "kubernetes_namespace" "fluxcd" {
  metadata { name = "fluxcd" }
}
