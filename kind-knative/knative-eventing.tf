resource "kustomization_resource" "knative_eventing" {
  manifest = jsonencode({
    "apiVersion" = "operator.knative.dev/v1alpha1"
    "kind"       = "KnativeEventing"
    "metadata"   = {
      "name"      = "knative-eventing"
      "namespace" = kubernetes_namespace.knative_eventing.metadata[0].name
    }
    "spec"       = { "version" = local.knative.eventing.version }
  })

  depends_on = [kustomization_resource.knative_operator]
}
