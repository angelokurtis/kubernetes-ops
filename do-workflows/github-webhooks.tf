locals {
  github_webhooks = {
    name = "github-webhooks"
    destination = { namespace = "workflows", server = "https://kubernetes.default.svc" }
    source = {
      path = "github-webhooks/base"
      repoURL = "https://github.com/angelokurtis/k8s-automation"
      targetRevision = "HEAD"
    }
  }
}