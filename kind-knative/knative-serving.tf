resource "kustomization_resource" "knative_serving" {
  manifest = jsonencode({
    "apiVersion" = "operator.knative.dev/v1alpha1"
    "kind"       = "KnativeServing"
    "metadata"   = {
      "name"      = "knative-serving"
      "namespace" = kubernetes_namespace.knative_serving.metadata[0].name
    }
    "spec"       = { "version" = local.knative.version }
  })

  depends_on = [kustomization_resource.knative_operator]
}
