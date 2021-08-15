locals {
  argo_events = {
    name = "argo-events"
    destination = { namespace = "events", server = "https://kubernetes.default.svc" }
    source = {
      chart = "argo-events"
      repoURL = "https://argoproj.github.io/argo-helm"
      targetRevision = "1.7.0"
      helm = {
        values = yamlencode({ singleNamespace = false })
      }
    }
  }
}