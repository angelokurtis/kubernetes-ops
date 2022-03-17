locals {
  default_application = {
    destination = { server = "https://kubernetes.default.svc" }
    finalizers  = ["resources-finalizer.argocd.argoproj.io"]
    namespace   = kubernetes_namespace.argo_cd.metadata[0].name
    project     = "default"
    syncPolicy  = { automated = { prune = true, selfHeal = true }, syncOptions = ["CreateNamespace=true"] }
  }
  applications = [
    merge(local.default_application, local.ingress_nginx),
  ]
}

resource "helm_release" "argo_cd" {
  name      = "argo-cd"
  namespace = kubernetes_namespace.argo_cd.metadata[0].name

  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  version    = "3.35.4"

  values = [
    yamlencode({
      fullnameOverride = "argo-cd",
      global           = { image = { repository : "argoproj/argocd", tag : "v2.3.1" } }
      server           = {
        extraArgs = ["--insecure"]
        config    = { url = "http://argocd.${local.cluster_host}" }
        ingress   = {
          enabled          = true
          ingressClassName = "nginx"
          hosts            = ["argocd.${local.cluster_host}"]
        }
        additionalApplications = local.applications
      }
      configs = {
        secret = {
          argocdServerAdminPassword      = "$2a$10$dA8Sbj49/zFgQM7NrPMC5.AfrFFcO7jppf8FaRyj1.p9QLRdcjdxi",
          argocdServerAdminPasswordMtime = time_static.now.rfc3339
        }
      }
    })
  ]
}

resource "kubernetes_namespace" "argo_cd" {
  metadata { name = "argo-cd" }
}

resource "time_static" "now" {}
