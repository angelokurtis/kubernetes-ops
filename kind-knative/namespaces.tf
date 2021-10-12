resource "kubernetes_namespace" "istio_system" {
  metadata {
    name   = "istio-system"
    labels = { istio-injection = "disabled" }
  }
}

resource "kubernetes_namespace" "knative_eventing" {
  metadata { name = "knative-eventing" }
}

resource "kubernetes_namespace" "knative_serving" {
  metadata { name = "knative-serving" }
}
