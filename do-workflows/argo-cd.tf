locals {
  default_application = {
    destination = { server = "https://kubernetes.default.svc" }
    finalizers = [ "resources-finalizer.argocd.argoproj.io" ]
    namespace = kubernetes_namespace.ops.metadata[0].name
    project = "default"
    syncPolicy = { automated = { prune = true, selfHeal = true }, syncOptions = [ "CreateNamespace=true" ] }
  }
  applications = [
    merge(local.default_application, local.argo_events),
    merge(local.default_application, local.argo_workflows),
    merge(local.default_application, local.cert_manager),
    merge(local.default_application, local.github_webhooks),
    merge(local.default_application, local.lets_encrypt),
    merge(local.default_application, local.sealed_secrets),
  ]
}

resource "helm_release" "argo_cd" {
  name = "argo-cd"
  namespace = kubernetes_namespace.ops.metadata[0].name

  repository = "https://argoproj.github.io/argo-helm"
  chart = "argo-cd"
  version = "3.11.1"

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
          enabled = true
          hosts = [ "argo-cd-${local.cluster_host}" ]
          https = true
          tls = [ { hosts = [ "argo-cd-${local.cluster_host}" ], secretName = "argo-cd-cert" } ]
          annotations = {
            "kubernetes.io/ingress.class": "nginx"
            "cert-manager.io/cluster-issuer": "letsencrypt-prod"
            "nginx.ingress.kubernetes.io/backend-protocol": "HTTPS"
            "nginx.ingress.kubernetes.io/ssl-redirect": "true"
          }
        }
        additionalApplications = local.applications
      }
    })
  ]
}

resource "kubernetes_namespace" "ops" {
  metadata { name = "continuous-deployment" }
}
