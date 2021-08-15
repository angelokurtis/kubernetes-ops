locals {
  github_webhooks = {
    name = "api-docs-eventsource"
    destination = { namespace = "events", server = "https://kubernetes.default.svc" }
    source = {
      path = "events"
      repoURL = "https://github.com/apirator/workflow-definitions"
      targetRevision = "HEAD"
    }
  }
}