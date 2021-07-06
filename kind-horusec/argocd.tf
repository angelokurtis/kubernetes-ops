resource "helm_release" "argocd" {
  count = var.argo_enabled ? 1 : 0

  name = "argocd"
  namespace = var.argo_namespace

  repository = "https://argoproj.github.io/argo-helm"
  chart = "argo-cd"
  version = "3.6.11"

  values = [
    yamlencode({
      fullnameOverride = "argocd",
      global = { image = { repository: "argoproj/argocd", tag: "v2.0.4" } }
      server = {
        extraArgs = [ "--insecure" ]
        ingress = { enabled = true, hosts = [ "argocd.local" ] }
        additionalApplications = [
          {
            destination = { namespace = "horusec-operator-system", server = "https://kubernetes.default.svc" }
            name = "horusec-operator"
            project = "default"
            source = {
              path = "config/default",
              repoURL = "https://github.com/ZupIT/horusec-operator",
              targetRevision = "v2.0.0"
            }
            syncPolicy = { automated = {}, syncOptions = [ "CreateNamespace=true" ] }
          }
        ]
      }
      configs = {
        secret = {
          argocdServerAdminPassword = bcrypt("admin"),
          argocdServerAdminPasswordMtime = "2021-05-01T00:00:00Z"
        } 
      }
    })
  ]
}

resource "kubernetes_namespace" "ops" {
  count = var.argo_enabled ? 1 : 0

  metadata {
    name = var.argo_namespace
  }
}
