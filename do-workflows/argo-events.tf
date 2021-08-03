locals {
  argo_events = {
    name = "argo-events"
    destination = { namespace = kubernetes_namespace.ops.metadata[0].name, server = "https://kubernetes.default.svc" }
    source = {
      chart = "argo-events"
      repoURL = "https://argoproj.github.io/argo-helm"
      targetRevision = "1.6.4"
    }
  }
}