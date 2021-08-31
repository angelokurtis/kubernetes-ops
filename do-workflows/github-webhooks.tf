locals {
  github_webhooks = {
    name = "api-docs-eventsource"
    destination = { namespace = "events", server = "https://kubernetes.default.svc" }
    source = {
      path = "do-workflows/overlays/nip.io"
      repoURL = "https://github.com/angelokurtis/kubernetes-ops"
      targetRevision = "HEAD"
    }
  }
}