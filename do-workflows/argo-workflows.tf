locals {
  argo_workflows = {
    name = "argo-workflows"
    destination = { namespace = kubernetes_namespace.ops.metadata[0].name, server = "https://kubernetes.default.svc" }
    source = {
      chart = "argo-workflows"
      repoURL = "https://argoproj.github.io/argo-helm"
      targetRevision = "0.2.12"
      helm = {
        values = yamlencode({
          server = {
            secure = true
            ingress = {
              enabled = true
              hosts = [ "argo-workflows-${local.cluster_host}" ]
              https = true
              tls = [ { hosts = [ "argo-workflows-${local.cluster_host}" ], secretName = "argo-workflows-cert" } ]
              annotations = {
                "kubernetes.io/ingress.class": "nginx"
                "cert-manager.io/cluster-issuer": "letsencrypt-prod"
                "nginx.ingress.kubernetes.io/backend-protocol": "HTTPS"
                "nginx.ingress.kubernetes.io/ssl-redirect": "true"
              }
            }
          }
        })
      }
    }
  }
}