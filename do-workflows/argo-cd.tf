resource "helm_release" "argo_cd" {
  name = "argo-cd"
  namespace = kubernetes_namespace.ops.metadata[0].name

  repository = "https://argoproj.github.io/argo-helm"
  chart = "argo-cd"
  version = "3.10.0"

  values = [
    yamlencode({
      "fullnameOverride" = "argo-cd",
      "global" = { "image" = { "repository": "argoproj/argocd", "tag": "v2.0.5" } }
      "server" = {
        "ingress" = { "enabled" = true, "hosts" = [ "argo-cd-${local.cluster_host}" ] }
      }
      "configs" = {
        "secret" = {
          "argocdServerAdminPassword" = "$2a$10$XgehbPznARhg75GhRgNNee/N/0bKsUWmdvvvuJ.W6JyNO/SGzuoRa",
          "argocdServerAdminPasswordMtime" = "2021-07-01T00:00:00Z"
        }
      }
    })
  ]
}

resource "kubernetes_namespace" "ops" {
  metadata { name = "continuous-deployment" }
}
