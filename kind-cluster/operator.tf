resource "helm_release" "istio_operator" {
  chart = "./manifests/charts/istio-operator"
  name = "istio-operator"

  set {
    name = "hub"
    value = "docker.io/istio"
  }
  set {
    name = "tag"
    value = "1.8.1"
  }
  set {
    name = "operatorNamespace"
    value = "istio-operator"
  }
}
