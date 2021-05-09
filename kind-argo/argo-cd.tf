resource "helm_release" "argo_cd" {
  name = "argo-cd"
  namespace = kubernetes_namespace.ops.metadata[0].name

  repository = "https://argoproj.github.io/argo-helm"
  chart = "argo-cd"
  version = "3.2.2"
}

resource "kubernetes_namespace" "ops" {
  metadata {
    name = "ops"
  }
}
