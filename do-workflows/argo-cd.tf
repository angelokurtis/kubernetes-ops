resource "helm_release" "argo_cd" {
  name = "argo-cd"
  namespace = kubernetes_namespace.ops.metadata[0].name

  repository = "https://argoproj.github.io/argo-helm"
  chart = "argo-cd"
  version = "3.10.0"

  values = [
    yamlencode({
      fullnameOverride = "argo-cd",
      global = { image = { repository: "argoproj/argocd", tag: "v2.0.5" } }
      configs = {
        secret = {
          argocdServerAdminPassword = "$2a$10$XgehbPznARhg75GhRgNNee/N/0bKsUWmdvvvuJ.W6JyNO/SGzuoRa",
          argocdServerAdminPasswordMtime = "2021-07-01T00:00:00Z"
        }
      }
      server = {
        ingress = {
          enabled = true,
          hosts = [ "argo-cd-${local.cluster_host}" ]
          annotations = { kubernetes.io/ingress.class: "nginx", cert-manager.io/cluster-issuer: "letsencrypt-prod" }
        }
        additionalApplications = [
          {
            destination = { namespace = "cert-manager", server = "https://kubernetes.default.svc" }
            finalizers = [ "resources-finalizer.argocd.argoproj.io" ]
            name = "cert-manager"
            namespace = "continuous-deployment"
            project = "default"
            source = {
              chart = "cert-manager"
              helm = { parameters = [ { name = "installCRDs", value = "true" } ] }
              repoURL = "https://charts.jetstack.io"
              targetRevision = "v1.4.1"
            }
            syncPolicy = { automated = { prune = true, selfHeal = true }, syncOptions = [ "CreateNamespace=true" ] }
          }
        ]
      }
    })
  ]
}

resource "kubernetes_namespace" "ops" {
  metadata { name = "continuous-deployment" }
}
