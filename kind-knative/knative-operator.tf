locals {
  knative = {
    operator = { version = "0.26.2" }
    eventing = { version = "0.26.1" }
    serving  = { version = "0.26.0" }
  }
}

data "kustomization_overlay" "knative_operator" {
  resources = ["https://github.com/knative/operator/releases/download/v${local.knative.operator.version}/operator.yaml"]
  namespace = "knative-operator"
}

resource "kustomization_resource" "knative_operator" {
  for_each = data.kustomization_overlay.knative_operator.ids
  manifest = data.kustomization_overlay.knative_operator.manifests[each.value]

  depends_on = [kubernetes_namespace.knative]
}

resource "kubernetes_namespace" "knative" {
  metadata { name = "knative-operator" }
}
