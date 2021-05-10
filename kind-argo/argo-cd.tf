resource "helm_release" "argo_cd" {
  name = "argo-cd"
  namespace = kubernetes_namespace.ops.metadata[0].name

  repository = "https://argoproj.github.io/argo-helm"
  chart = "argo-cd"
  version = "3.2.2"

  values = [
    yamlencode({
      "server" = {
        "extraArgs" = [ "--insecure" ]
        "ingress" = {
          "enabled" = true
          "hosts" = [ "argo-cd.ops.local" ]
        }
      }
    })
  ]
}

resource "kubernetes_namespace" "ops" {
  metadata {
    name = "ops"
  }
}
