locals {
  argo_rollouts = {
    name        = "argo-rollouts"
    destination = {
      namespace = kubernetes_namespace.argo_rollouts.metadata[0].name
      server    = "https://kubernetes.default.svc"
    }
    source = {
      chart          = "argo-rollouts"
      repoURL        = "https://argoproj.github.io/argo-helm"
      targetRevision = "2.x.x"
      helm           = {
        values = yamlencode({
          controller = {
            # fixes issue https://github.com/argoproj/argo-rollouts/issues/1619
            image = { registry = "quay.io", repository = "argoproj/argo-rollouts", tag = "v1.2.0-rc2" }
          }
          dashboard = {
            enabled = true
            image   = { registry = "quay.io", repository = "argoproj/kubectl-argo-rollouts", tag = "v1.2.0-rc2" }
            ingress = { enabled = true, ingressClassName = "nginx", hosts = ["argorollouts.${local.cluster_host}"] }
          }
        })
      }
    }
  }
}

resource "kubernetes_namespace" "argo_rollouts" {
  metadata { name = "argo-rollouts" }
}
