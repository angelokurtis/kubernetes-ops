resource "helm_release" "argo_events" {
  name = "argo-events"
  namespace = kubernetes_namespace.events.metadata[0].name

  repository = "https://argoproj.github.io/argo-helm"
  chart = "argo-events"
  version = "1.6.4"
}

resource "kustomization_resource" "eventbus" {
  manifest = jsonencode({
    apiVersion = "argoproj.io/v1alpha1"
    kind = "EventBus"
    metadata = { name = "default", namespace = kubernetes_namespace.events.metadata[0].name }
    spec = { nats = { native = { auth = "token", replicas = 3 } } }
  })

  depends_on = [ helm_release.argo_events ]
}

resource "kubernetes_namespace" "events" {
  metadata { name = "events" }
}
